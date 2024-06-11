import currentUser from "$stores/currentUser";
import { ndk } from "$stores/ndk";
import { userFollows } from "$stores/session";
import { NDKUser } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function toggleFollow(user: NDKUser) {
    const $currentUser = get(currentUser);
    const $ndk = get(ndk);
    const $userFollows = get(userFollows);

    if (!$currentUser) return;
    
    if ($userFollows.size === 0) {
        if (!confirm("We have not found any follows, if you continue and you currently following people your follows list will be emptied. Do you want to continue?")) {
            return;
        }
    }
    
    const currentFollows = new Set<NDKUser>();
    for (const pubkey of $userFollows) { currentFollows.add($ndk.getUser({pubkey}))}

    if (!$userFollows.has(user.pubkey)) {
        $currentUser?.follow(user, currentFollows);
    } else {
        $currentUser?.unfollow(user, currentFollows);
    }
}