import { loginState } from '$stores/session';
import { loggedIn, login, type LoginMethod } from '$utils/login';
import { ndk, user } from '@kind0/ui-common';
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
export async function browserSetup() {
    const pubkey = localStorage.getItem('pubkey');
    d({pubkey});

    if (pubkey) {
        const u = $ndk.getUser({pubkey});
        loginState.set("logging-in");
        user.set(u);
    }

    const method = localStorage.getItem('nostr-key-method') as LoginMethod;

    // No stored pubkey found, attempt to sign in with NIP-07
    if (!pubkey && method !== "none") return newSessionTryNip07();

    if (method) {
        return login(method, pubkey);
    }
}

export async function newSessionTryNip07() {
    let signer: NDKNip07Signer | undefined;
    let u: NDKUser | null | undefined;

    try {
        d('trying nip07 signer');
        signer = new NDKNip07Signer();
        u = await signer.blockUntilReady();
    } catch (e) { d('nip07Signer failed', e); }

    if (u && signer) {
        d('nip07Signer succeeded');
        loggedIn(signer, u, 'nip07');
    }
}

