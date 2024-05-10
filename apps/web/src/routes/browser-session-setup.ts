import { isGuest, loginMethod, privateKey, userPubkey } from '$stores/currentUser';
import { loginState } from '$stores/session';
import { fillInSkeletonProfile, loggedIn, login, type LoginMethod } from '$utils/login';
import { ndk, user } from '@kind0/ui-common';
import { NDKNip07Signer, NDKPrivateKeySigner, NDKUser } from '@nostr-dev-kit/ndk';
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
    const pubkey = get(userPubkey);
    d({pubkey});

    if (pubkey) {
        const u = $ndk.getUser({pubkey});
        loginState.set("logging-in");
        user.set(u);
    }

    const method = get(loginMethod);

    // No stored pubkey found, attempt to sign in with NIP-07
    if (!pubkey && method !== "none") {
        const loggedIn = await newSessionTryNip07();
        const $ndk = get(ndk);

        if (!$ndk.signer) {
            return await newGuestLogin();
        }

        return;
    }

    if (method) {
        return login(method, pubkey);
    }
}

export async function newGuestLogin() {
    const pk = NDKPrivateKeySigner.generate();
    const u = await pk.user();
    const $ndk = get(ndk);

    loginMethod.set('guest');
    userPubkey.set(u.pubkey);
    privateKey.set(pk.privateKey!);

    login('guest', u.pubkey);

    $ndk.signer = pk;
    const us = await $ndk.signer?.blockUntilReady();
    us.ndk = $ndk;
    user.set(us);

    fillInSkeletonProfile({
        image: `https://api.dicebear.com/8.x/rings/svg?seed=${u.pubkey}&ringColor=FB6038`
    });
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

