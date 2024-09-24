import { GroupData, loadGroupsData } from "$components/Groups";
import NDK, { NDKEvent, NDKKind, NDKList, NDKRelaySet, tryNormalizeRelayUrl } from "@nostr-dev-kit/ndk";
import { derived, get, writable } from "svelte/store";
import currentUser from "./currentUser";
import NDKSvelte from "@nostr-dev-kit/ndk-svelte";

export const groups = writable<GroupData[]>([])
export const myGroups = derived([groups, currentUser], ([$groups, $currentUser]) => {
    if (!$currentUser) return [];

    const userIsGroupAdmin = (group: GroupData) => group.admins?.memberSet.has($currentUser.pubkey);

    return $groups
        .filter(userIsGroupAdmin)
})

export function initGroups(
    userGroupList: NDKList
) {
    console.log('userGroupList')
    console.log(userGroupList)
    // const store = loadGroupsData(userGroupList.items);
    // store.subscribe((data: Record<string, GroupData>) => groups.set(Object.values(data)) )
    
    // // a map of relay urls and the group IDs
    // const groupsPerRelays: Record<string, string[]> = {};

    // for (const tag of userGroupList.items) {
    //     const [ _, groupId, ...relays ] = tag;
    //     const urls = relays.map(tryNormalizeRelayUrl).join(' ')
    //     let val = groupsPerRelays[urls] ?? [];
    //     val.push(groupId);
    //     groupsPerRelays[urls] = val;
    // }

    // // we have all the group IDs in sets so that we can now query the right relays
    // for (const [relayUrls, groupIds] of Object.entries(groupsPerRelays)) {
    //     const relaySet = NDKRelaySet.fromRelayUrls(relayUrls.split(/ /), ndk);

    //     const sub = ndk.subscribe([
    //         { kinds: [NDKKind.GroupMetadata, NDKKind.GroupAdmins, NDKKind.GroupMembers], "#d": groupIds }
    //     ], { groupable: true, groupableDelay: 20 }, relaySet, false);

    //     sub.on('event', processEvent);
        
    //     sub.start();
    // }
}