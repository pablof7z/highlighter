import currentUser, { loginMethod, userPubkey, privateKey } from "$stores/currentUser";
import { ndk } from "$stores/ndk"
import { login, fillInSkeletonProfile } from "$utils/login";
import { NDKPrivateKeySigner } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store"

export async function createGuestAccount() {
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
    currentUser.set(us);

    fillInSkeletonProfile({
        image: `https://api.dicebear.com/8.x/rings/svg?seed=${u.pubkey}&ringColor=FB6038`
    });
}