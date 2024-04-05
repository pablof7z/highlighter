import type NDK from '@nostr-dev-kit/ndk';
import {
	NDKEvent,
	NDKNip07Signer,
	NDKNip46Signer,
	NDKPrivateKeySigner,
	NDKUser,
	type NDKSigner,
	type Hexpubkey,
	type NDKUserProfile
} from '@nostr-dev-kit/ndk';
import { bunkerNDK, ndk, newToasterMessage, user } from '@kind0/ui-common';
import { generateLoginEvent } from '$actions/signLoginEvent';
import { get } from 'svelte/store';
import { jwt as jwtStore, loginState } from '$stores/session';
import createDebug from 'debug';
import currentUser from '$stores/currentUser';
import { goto } from '$app/navigation';

export type LoginMethod = 'none' | 'pk' | 'nip07' | 'nip46';

const d = createDebug('HL:login');
const $ndk = get(ndk);
const $bunkerNDK = get(bunkerNDK);

export async function finalizeLogin() {
	const hostname = import.meta.env.VITE_HOSTNAME;
	// fetch jwt
	const loginEvent = await generateLoginEvent(hostname);
	if (!loginEvent) return null;
	const jwt = await fetchJWT(loginEvent);
	if (jwt) {
		jwtStore.set(jwt);
		document.cookie = `jwt=${jwt}; path=/; domain=${hostname};`;
	}
}

async function pkLogin(key: string) {
	const signer = new NDKPrivateKeySigner(key);
	const u = await signer.user();
	if (u) loggedIn(signer, u!, 'pk');
}

async function nip46Login(remotePubkey?: Hexpubkey) {
	const existingPrivateKey = localStorage.getItem('nostr-nsecbunker-key');
	let remoteUser: NDKUser | undefined;

	d({ existingPrivateKey, remotePubkey });

	if (!existingPrivateKey) return;

	// If we already a pubkey
	if (remotePubkey) remoteUser = $ndk.getUser({ pubkey: remotePubkey! });

	if (!remoteUser) return;

	user.set(remoteUser);
	console.log("DEBUG setting user", remoteUser)
	$bunkerNDK.pool.on('relay:ready', async () => {
		d('bunker relay ready');
		loginState.set('contacting-remote-signer');

		await nip46SignIn(existingPrivateKey, remoteUser!);
	});
	d('connecting to nsecbunker relay');
	$bunkerNDK.connect(2500);
}

/**
 * This function attempts to sign in using whatever method was previously
 * used, or a NIP-07 extension.
 */
export async function login(
	method: LoginMethod,
	userPubkey?: string,
) {
	d(`running with method ${method}`);

	// Check if there is a localStorage item with the key "nostr-key-method"
	method ??= localStorage.getItem('nostr-key-method') as LoginMethod;
	let u: NDKUser | null | undefined;

	switch (method) {
		case 'none': {
			loginState.set(null);
			return null;
		}
		case 'pk': {
			const key = localStorage.getItem('nostr-key');
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
						const user = nip07SignIn(ndk);
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
	const storedPubkey = localStorage.getItem('pubkey');
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
				localStorage.setItem('nostr-key-method', 'nip07');
			}
			localStorage.setItem('pubkey', user.pubkey);
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
	await remoteSigner.blockUntilReady();
	d(`Remote signer came back`);

	localStorage.setItem('nostr-nsecbunker-key', localSigner.privateKey!);
	loggedIn(remoteSigner, remoteUser, 'nip46');
}

export function loggedIn(signer: NDKSigner, u: NDKUser, method: LoginMethod) {
	$ndk.signer = signer;
    u.ndk = $ndk;
    user.set(u)
	console.log("DEBUG setting user (loggedIn)", u)
    loginState.set("logged-in");

    localStorage.setItem('pubkey', u.pubkey);
    localStorage.setItem('nostr-key-method', method);
}

export function logout(): void {
	const $ndk = get(ndk);
	$ndk.signer = undefined;
	user.set(undefined);
	currentUser.set(undefined);
	console.log("DEBUG setting user (logout)");
	loginState.set('logged-out');
	localStorage.removeItem('currentUserFollowPubkeysStore');
	localStorage.removeItem('currentUserStore');
	localStorage.removeItem('user-follows');
	localStorage.removeItem('user-super-follows');
	localStorage.removeItem('network-follows');
	localStorage.removeItem('network-follows-updated-t');
	localStorage.removeItem('currentUserNpub');
	localStorage.removeItem('pubkey');
	localStorage.removeItem('jwt');

	document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';

	// explicitly prevent auto-login with NIP-07
	localStorage.setItem('nostr-key-method', 'none');

	goto('/');
}

export async function fillInSkeletonProfile(profile: NDKUserProfile) {
	const images = [
        "https://cdn.satellite.earth/aaf65dd621667c75162ce3ee845a8202bdf2aee8d70ec0f1d25fe92ecd881675.png",
        "https://cdn.satellite.earth/c50267d41d5874cb4e949e7bd472c2d06e1b297ffffac19b2f53c291a3e052d2.png",
        "https://cdn.satellite.earth/011dc8958f86dc12c5c3a477de3551c3077fb8e71a730b7cec4a678f5c021550.png",
    ];
	const randImage = images[Math.floor(Math.random() * images.length)];

	profile.image = randImage;
	profile.about = `Hi! I'm a brand new nostr user trying things out. Be nice!`;
	profile.website = "";

	console.log('fillInSkeletonProfile', profile);

	const $user = get(user);
	$user.profile = profile;
    await $user.publish();
}