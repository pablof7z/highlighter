import { ndk } from "$stores/ndk";
import { groupsList } from "$stores/session";
import { NDKKind, NDKList, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function pinGroup(group: NDKSimpleGroup) {
    const $ndk = get(ndk);
    const $groupsList = get(groupsList);
    
    if (!$groupsList) groupsList.set(new NDKList($ndk));

    if (!$groupsList) return;

    $groupsList.kind = NDKKind.SimpleGroupList;

    const groupData = {
        id: group.groupId,
        relayUrls: group.relayUrls(),
    }

    $groupsList.addItem([ "group", group.groupId, ...group.relayUrls() ]);
    await $groupsList.publishReplaceable();
}