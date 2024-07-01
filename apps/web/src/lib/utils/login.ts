import type NDK from '@nostr-dev-kit/ndk';
import {
	NDKEvent,
	NDKNip07Signer,
	NDKNip46Signer,
	NDKPrivateKeySigner,
	NDKUser,
	type NDKSigner,
	type Hexpubkey,
	type NDKUserProfile,
	NDKKind,
	NDKRelayList
} from '@nostr-dev-kit/ndk';
import { generateLoginEvent } from '$actions/signLoginEvent';
import { get } from 'svelte/store';
import { jwt as jwtStore, loginState, userFollows, userProfile } from '$stores/session';
import createDebug from 'debug';
import currentUser, { loginMethod, nip46LocalKey, privateKey, userPubkey } from '$stores/currentUser';
import { goto } from '$app/navigation';
import { vanityUrls } from './const';
import { ndk, bunkerNDK } from '$stores/ndk';
import { newToasterMessage } from '$stores/toaster';
import { nip19 } from 'nostr-tools';

export type LoginMethod = 'none' | 'pk' | 'npub' | 'nip07' | 'nip46' | 'guest';

const d = createDebug('HL:login');
const $ndk = get(ndk);
const $bunkerNDK = get(bunkerNDK);

export async function finalizeLogin() {
	const url = import.meta.env.VITE_BASE_URL;
	const hostname = new URL(url).hostname;
	// fetch jwt
	// const loginEvent = await generateLoginEvent(hostname);
	// if (!loginEvent) return null;
	// const jwt = await fetchJWT(loginEvent);
	// if (jwt) {
	// 	jwtStore.set(jwt);
	// 	document.cookie = `jwt=${jwt}; path=/; domain=${hostname};`;
	// }
}

async function pkLogin(key: string, method: LoginMethod = 'pk') {
	try {
		const signer = new NDKPrivateKeySigner(key);
		const u = await signer.user();
		if (u) loggedIn(signer, u!, method);
	} catch {
		loginMethod.set(undefined);
		privateKey.set(undefined);
		userPubkey.set(null);
		login()
	}
}

async function nip46Login(remotePubkey?: Hexpubkey) {
	const existingPrivateKey = nip46LocalKey.get();
	let remoteUser: NDKUser | undefined;

	d({ existingPrivateKey, remotePubkey });

	if (!existingPrivateKey) return;

	// If we already a pubkey
	if (remotePubkey) remoteUser = $ndk.getUser({ pubkey: remotePubkey! });

	if (!remoteUser) return;

	currentUser.set(remoteUser);
	console.log("DEBUG setting user", remoteUser)
	const connected = async () => {
		d('bunker relay ready');
		loginState.set('contacting-remote-signer');

		await nip46SignIn(existingPrivateKey, remoteUser!);
	}
	$bunkerNDK.pool.on('relay:ready', connected);
	d('connecting to nsecbunker relay');
	await $bunkerNDK.connect(2500);
	$bunkerNDK.pool.off('relay:ready', connected);
}

function determineMethodFromPayload(payload: string) {
	if (payload.startsWith("nsec")) {
		try {
			const key = new NDKPrivateKeySigner(payload);
			privateKey.set(key.privateKey);
			return "pk";
		} catch (e) {
			console.error(e);
		}
	}

	return "none";
}

/**
 * This function attempts to sign in using whatever method was previously
 * used, or a NIP-07 extension.
 */
export async function login(payload: string | undefined) {
	let method: LoginMethod | undefined;
	
	if (payload) method = determineMethodFromPayload(payload);
	
	d(`running with method ${method}`);

	// Check if there is a localStorage item with the key "nostr-key-method"
	method ??= get(loginMethod);
	let u: NDKUser | null | undefined;

	switch (method) {
		case 'none': {
			loginState.set(null);
			return null;
		}
		case 'guest':
			const key = get(privateKey);
			if (!key) return null;
			return pkLogin(key, 'guest');
		case 'pk': {
			const key = get(privateKey);
			if (!key) return null;
			return pkLogin(key);
		}
		case 'nip07':
			u = await nip07SignIn($ndk);
			loginState.set('logged-in');
			break;
		case 'nip46': {
			return nip46Login(userPubkey);
		}
		default: {
			const promise = new Promise<NDKUser | null>((resolve) => {
				// Attempt to see window.nostr a few times, there is a race condition
				// since the page might begin rendering before the nostr extension is loaded
				let loadAttempts = 0;
				const loadNip07Interval = setInterval(async () => {
					if (window.nostr) {
						clearInterval(loadNip07Interval);
						const user = nip07SignIn($ndk);
						// await finalizeLogin();
						resolve(user);
					}

					if (loadAttempts++ > 10) clearInterval(loadNip07Interval);
				}, 100);
			});

			return promise;
		}
	}
}

export async function fetchJWT(event: NDKEvent) {
	const formData = new FormData();
	formData.append('event', JSON.stringify(event.rawEvent()));

	const res = await fetch('/api/login', {
		method: 'POST',
		headers: { accept: 'application/json' },
		body: JSON.stringify({ event: event.rawEvent() })
	});

	if (res.status !== 200) {
		let error: string;
		const data = await res.json();
		console.log(data);

		error = data.error;
		error ??= res.statusText;

		newToasterMessage(`Failed to login: ${error.message}`, 'error');
		return false;
	}

	const jwt = await res.text();

	return jwt;
}

/**
 * This function attempts to sign in using a NIP-07 extension.
 */
async function nip07SignIn(ndk: NDK): Promise<NDKUser | null> {
	const storedPubkey = get(userPubkey);
	let user: NDKUser | null = null;

	if (storedPubkey) {
		user = new NDKUser({ npub: storedPubkey });
		user.ndk = ndk;
	}

	if (window.nostr) {
		try {
			ndk.signer = new NDKNip07Signer();
			user = await ndk.signer?.blockUntilReady();
			user.ndk = ndk;
			if (user) {
				loginMethod.set('nip07');
			}
			userPubkey.set(user.pubkey);
		} catch (e) {}
	}

	return user;
}

/**
 * This function attempts to sign in using a NIP-46 extension.
 */
async function nip46SignIn(
	existingPrivateKey: string,
	remoteUser: NDKUser
) {
	remoteUser.ndk = $bunkerNDK;

	// check if there is a private key stored in localStorage
	let localSigner: NDKPrivateKeySigner | null = null;

	if (existingPrivateKey) {
		localSigner = new NDKPrivateKeySigner(existingPrivateKey);
	}

	if (!localSigner) {
		alert('Local signer not available');
		return null;
	}

	const remoteSigner = new NDKNip46Signer($bunkerNDK, remoteUser.pubkey, localSigner!);

	d(`Contacting remote signer`);
	remoteSigner.blockUntilReady();
	d(`Remote signer came back`);

	localStorage.setItem('nostr-nsecbunker-key', localSigner.privateKey!);
	loggedIn(remoteSigner, remoteUser, 'nip46');
}

export function loggedIn(signer: NDKSigner, u: NDKUser, method: LoginMethod) {
	$ndk.signer = signer;
    u.ndk = $ndk;
    currentUser.set(u)
	console.trace("DEBUG setting user (loggedIn)", u)
    loginState.set("logged-in");

	loginMethod.set(method);
	userPubkey.set(u.pubkey);
}

export function logout(): void {
	const $ndk = get(ndk);
	$ndk.signer = undefined;
	currentUser.set(undefined);
	currentUser.set(undefined);
	loginState.set('logged-out');
	userFollows.set(new Set());
	userFollows.delete();
	userPubkey.set("");
	userProfile.set(undefined);

	// explicitly prevent auto-login with NIP-07
	loginMethod.set('none');

	goto('/');
}

const names = [
	"Curious Reader",
	"The Eager Explorer",
	"A Thoughtful Thinker",
	"The Avid Annotator",
	"A Voracious Viewer",
	"The Inquisitive Intellect",
	"A Knowledge Knight",
	"The Pensive PageTurner",
	"A Reflective Reader",
	"The Scholarly Seeker",
	"A Wise Wanderer",
	"The Captivated Curator",
	"A Diligent Discoverer",
	"The Open-Minded Observer",
	"A Insightful Inquirer",
	"The Focused Forager",
	"A Bright Bibliophile",
	"The Wandering Wordsmith",
	"A Engaged Explorer",
	"The Investigative Imbiber",
	"A Mindful Maven"
];

export async function fillInSkeletonProfile(profile: NDKUserProfile) {
	const images = [
        "https://cdn.satellite.earth/aaf65dd621667c75162ce3ee845a8202bdf2aee8d70ec0f1d25fe92ecd881675.png",
        "https://cdn.satellite.earth/c50267d41d5874cb4e949e7bd472c2d06e1b297ffffac19b2f53c291a3e052d2.png",
        "https://cdn.satellite.earth/011dc8958f86dc12c5c3a477de3551c3077fb8e71a730b7cec4a678f5c021550.png",
    ];
	const randName = names[Math.floor(Math.random() * names.length)];
	const randImage = images[Math.floor(Math.random() * images.length)];

	profile.name ??= randName;
	profile.image ??= randImage;
	profile.about ??= `Hi! I'm a brand new nostr user trying things out. Be nice!`;
	profile.website ??= "";

	const followList = new NDKEvent($ndk);
	followList.kind = NDKKind.Contacts;
	// followList.tags = Object.values(vanityUrls).map((pubkey) => [ "p", pubkey ]);

	followList.publish().catch(e => console.error('Failed to publish follow list', e));
	
	const $currentUser = get(currentUser);
	$currentUser.profile = profile;
    const r = $currentUser.publish().catch(e => console.error('Failed to publish user profile', e));
	console.log('publish user profile', r);

	const relayList = new NDKRelayList($ndk);
	relayList.bothRelayUrls = $ndk.pool.connectedRelays().map((r) => r.url);
	relayList.publish().catch(e => console.error('Failed to publish relay list', e));
}