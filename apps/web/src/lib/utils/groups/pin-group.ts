import { ndk } from "$stores/ndk";
import { groupsList } from "$stores/session";
import { NDKKind, NDKList, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function pinGroup(group: NDKSimpleGroup) {
    const $ndk = get(ndk);
    const list = get(groupsList) ?? new NDKList($ndk);
    
    list.kind = NDKKind.SimpleGroupList;

    const groupData = {
        id: group.groupId,
        relayUrls: group.relayUrls(),
    }

    list.addItem([ "group", group.groupId, ...group.relayUrls() ]);

    const push = await list.publishReplaceable();
    console.log(push);
}