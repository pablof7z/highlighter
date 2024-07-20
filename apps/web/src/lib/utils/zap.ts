import NDK, { NDKEvent, NDKPrivateKeySigner, NDKSigner, NDKTag, NDKUser, type Hexpubkey } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { wallet } from "$stores/wallet";
import { toast } from "svelte-sonner";
import { ndk } from "$stores/ndk";

export async function zap(
    amount: number,
    target: NDKEvent | NDKUser,
    comment?: string,
) {
    const $ndk = get(ndk);

    $ndk.zap(target, amount, comment, [], "msats");
}
