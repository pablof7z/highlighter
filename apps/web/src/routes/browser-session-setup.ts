import currentUser, { loginMethod, nip46LocalKey, userPubkey } from '$stores/currentUser';
import { ndk } from '$stores/ndk';
import { loginState } from '$stores/session';
import { loggedIn, login, nip46Login, nip46SignIn } from '$utils/login';
import { createGuestAccount } from '$utils/user/guest';
import { NDKNip07Signer, NDKUser } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { get } from 'svelte/store';

const d = createDebug('HL:boot');

const $ndk = get(ndk);

/**
 * Entry-point to start the local session
 *
 * This function will attempt to restore state from a previous session,
 * setting up a global user as soon as possible and connecting with the
 * signer in the background when possible.
 */
export async function browserSetup(useGuest = true) {
    const pubkey = get(userPubkey);
    d('pubkey %s', pubkey);

    if (pubkey) {
        const u = $ndk.getUser({pubkey});
        loginState.set("logging-in");
    }

    const method = get(loginMethod);
    d('login method %s', method);

    if (method === 'nip46' && pubkey) {
        await nip46Login(pubkey)
    } else {
        // No stored pubkey found, attempt to sign in with NIP-07
        if (!pubkey && method !== "none") {
            const loggedIn = await newSessionTryNip07();
            const $ndk = get(ndk);

            if (!$ndk.signer) {
                if (useGuest)
                    return await createGuestAccount();
            }

            return;
        }

        if (method) {
            return login();
        }
    }
}

export async function newSessionTryNip07() {
    let signer: NDKNip07Signer | undefined;
    let u: NDKUser | null | undefined;

    try {
        d('trying nip07 signer');
        signer = new NDKNip07Signer();
        u = await signer.blockUntilReady();
        loginMethod.set('nip07');
    } catch (e) { d('nip07Signer failed', e); }

    if (u && signer) {
        d('nip07Signer succeeded');
        loggedIn(signer, u, 'nip07');
    }
}

