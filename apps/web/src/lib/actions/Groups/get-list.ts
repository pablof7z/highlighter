import { ndk } from "$stores/ndk";
import { groupsList } from "$stores/session";
import { NDKKind, NDKList } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export default function (): NDKList {
    const $groupsList = get(groupsList);
    if ($groupsList) {
        return $groupsList;
    }

    const $ndk = get(ndk);
    const list = new NDKList($ndk);
    list.kind = NDKKind.SimpleGroupList;
    return list;
}