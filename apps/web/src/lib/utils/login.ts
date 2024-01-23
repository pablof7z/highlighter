import type NDK from '@nostr-dev-kit/ndk';
import {
	NDKEvent,
	NDKNip07Signer,
	NDKNip46Signer,
	NDKPrivateKeySigner,
	NDKUser
} from '@nostr-dev-kit/ndk';
import { ndk, newToasterMessage, user } from '@kind0/ui-common';
import { generateLoginEvent } from '$actions/signLoginEvent';
import { get } from 'svelte/store';
import { jwt as jwtStore, loginState } from '$stores/session';
import createDebug from 'debug';

export type LoginMethod = 'none' | 'pk' | 'nip07' | 'nip46';

const d = createDebug('highlighter:login');

/**
 * These are pubkeys managed by the relay running this app, which gates access to content
 */
export const trustedPubkeys = [
	'4f7bd9c066a7b21d750b4e8dbf4440ef1e80c64864341550200b8481d530c5ce' // faaans
];

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

/**
 * This function attempts to sign in using whatever method was previously
 * used, or a NIP-07 extension.
 */
export async function login(
	ndk: NDK,
	bunkerNDK: NDK,
	method: LoginMethod
): Promise<NDKUser | null> {
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

			const signer = new NDKPrivateKeySigner(key);
			ndk.signer = signer;
			const u = await signer.user();
			if (u) u.ndk = ndk;

			loginState.set('logged-in');
			break;
		}
		case 'nip07':
			u = await nip07SignIn(ndk);
			loginState.set('logged-in');
			break;
		case 'nip46': {
			const promise = new Promise<NDKUser | null>((resolve) => {
				const existingPrivateKey = localStorage.getItem('nostr-nsecbunker-key');
				const storedNpub = localStorage.getItem('nostr-target-npub');

				if (storedNpub) {
					u = ndk.getUser({ npub: storedNpub! });
				}

				if (!bunkerNDK) bunkerNDK = ndk;

				if (existingPrivateKey && u) {
					user.set(u);
					bunkerNDK.pool.on('relay:ready', async () => {
						console.log('relay ready');
						loginState.set('contacting-remote-signer');

						const completeNip46SignIn = async () => {
							const signedInUser = await nip46SignIn(ndk, bunkerNDK!, existingPrivateKey);
							if (!signedInUser) {
								user.set(null);
								loginState.set('logged-out');
								return;
							}

							await finalizeLogin();
							loginState.set('logged-in');
							resolve(signedInUser);
						};

						await Promise.race([
							new Promise<void>((resolve) =>
								setTimeout(() => {
									if (get(loginState) !== 'contacting-remote-signer') return;
									newToasterMessage('Failed to connect to remote signer', 'error');
									resolve();
								}, 5000)
							),
							new Promise((resolve) => {
								completeNip46SignIn().then(resolve);
							})
						]);
					});
					console.log('connecting to nsecbunker relay');
					bunkerNDK.connect(2500);
				}
			});

			return promise;
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

	console.log('login', { u });

	if (!u) return null;

	const $jwt = get(jwtStore);
	if (!$jwt) await finalizeLogin();

	user.set(u);
	return u;
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

	const { jwt } = await res.json();

	return jwt;
}

/**
 * This function attempts to sign in using a NIP-07 extension.
 */
async function nip07SignIn(ndk: NDK): Promise<NDKUser | null> {
	console.trace(`localStorage access`);
	const storedNpub = localStorage.getItem('nostr-target-npub');
	let user: NDKUser | null = null;

	if (storedNpub) {
		user = new NDKUser({ npub: storedNpub });
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
			localStorage.setItem('nostr-target-npub', user.npub);
		} catch (e) {}
	}

	return user;
}

/**
 * This function attempts to sign in using a NIP-46 extension.
 */
async function nip46SignIn(
	ndk: NDK,
	bunkerNDK: NDK,
	existingPrivateKey: string
): Promise<NDKUser | null> {
	const npub = localStorage.getItem('nostr-target-npub')!;
	const remoteUser = new NDKUser({ npub });
	let user: NDKUser | null = null;
	remoteUser.ndk = bunkerNDK;

	// check if there is a private key stored in localStorage
	let localSigner: NDKPrivateKeySigner | null = null;

	if (existingPrivateKey) {
		localSigner = new NDKPrivateKeySigner(existingPrivateKey);
	}

	if (!localSigner) {
		alert('Local signer not available');
		return null;
	}

	const remoteSigner = new NDKNip46Signer(bunkerNDK, remoteUser.pubkey, localSigner!);

	console.log('nip46 blockUntilReady');
	await remoteSigner.blockUntilReady();
	console.log('nip46 blockUntilReady done');
	ndk.signer = remoteSigner;
	console.log('setting signer on nip46SignIn');
	user = remoteUser;
	user.ndk = ndk;

	return user;
}

export function logout(): void {
	const $ndk = get(ndk);
	$ndk.signer = undefined;
	user.set(undefined);
	loginState.set('logged-out');
	localStorage.removeItem('currentUserFollowPubkeysStore');
	localStorage.removeItem('currentUserStore');
	localStorage.removeItem('user-follows');
	localStorage.removeItem('user-super-follows');
	localStorage.removeItem('network-follows');
	localStorage.removeItem('network-follows-updated-t');
	localStorage.removeItem('currentUserNpub');
	localStorage.removeItem('nostr-target-npub');
	localStorage.removeItem('jwt');

	document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';

	// explicitly prevent auto-login with NIP-07
	localStorage.setItem('nostr-key-method', 'none');
}
