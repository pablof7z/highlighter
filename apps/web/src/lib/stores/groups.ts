import { derived, get, Readable, Writable, writable } from 'svelte/store';
import NDK, { Hexpubkey, NDKEvent, NDKFilter, NDKKind, NDKList, NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionCacheUsage, NDKTag, normalizeRelayUrl } from "@nostr-dev-kit/ndk";
import { groupsList } from './session';
import { ndk } from './ndk';
import createDebug from 'debug';

const d = createDebug('HL:groups');

export type GroupEntryKey = string;
export let groupRefs = new Map<GroupEntryKey, number>();


export type GroupEntry = {
    groupId: string;
    relaySet: NDKRelaySet;
    relayUrls: string[];
    
    metadata?: NDKSimpleGroupMetadata;
    name?: string;
    about?: string;
    picture?: string;

    membersList?: NDKSimpleGroupMemberList;
    members: Set<Hexpubkey>;

    adminsList?: NDKSimpleGroupMemberList;
    admins: Set<Hexpubkey>;
};

export let groups = writable<Record<string, GroupEntry>>({});

async function loadMostRecentEventFromCache(groupId: string) {
    const $ndk = get(ndk);
    if (!$ndk.cacheAdapter) {
        d("No cache adapter, skipping cache load");
        return;
    }

    const event = await $ndk.fetchEvent({ "#h": [groupId], limit: 1 });

    if (!event) {
        d("No event found in cache for group", {groupId});
        return;
    }

    return event.created_at;
}

const startedGroups = new Set<string>();

async function startGroup(groupId: string, relays: string[]) {
    const $ndk = get(ndk);
    const relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);
    d(`Starting group ${groupId}`, {relays});

    const filters: NDKFilter[] = [
        { kinds: [NDKKind.GroupNote, NDKKind.GroupReply ], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.GroupChat ], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.Article ], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.Wiki ], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.Media ], "#m": ["video/mp4"], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.Highlight ], "#h": [groupId], limit: 50 },
        { kinds: [NDKKind.SubscriptionTier ], "#h": [groupId], limit: 50 },
    ];

    // // const cachedEvents = await $ndk.fetchEvents(filters, { cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE });

    // // d("Cached events for group", {groupId, cachedEvents});

    // // // go through the results and get the most recent event of each type
    // // const mostRecentPerFilterIndex: Record<number, number> = {};
    // // for (const event of cachedEvents) {
    // //     const filterIndex = filters.findIndex(filter => filter.kinds!.includes(event.kind!));

    // //     if (!filterIndex) {
    // //         d("Event doesn't match any filter! %o %o", {kind: event.kind}, filters);
    // //         continue;
    // //     }

    // //     const currentVal = mostRecentPerFilterIndex[filterIndex] ?? 0;

    // //     if (event.created_at! > currentVal) {
    // //         mostRecentPerFilterIndex[filterIndex!] = event.created_at!;
    // //     }
    // // }

    // // // add a since on the filters
    // // for (const [i, mostRecent] of Object.entries(mostRecentPerFilterIndex)) {
    // //     if (mostRecent) filters[Number(i)].since = mostRecent;
    // // }

    // d("Result is %o", {mostRecentPerFilterIndex, filters});

    // filters that shouldn't have a since
    filters.push({ kinds: [
        NDKKind.GroupAdmins, NDKKind.GroupMembers,
    ], "#d": [groupId] });

    const defaultGroupEntry: GroupEntry = { groupId, relaySet, relayUrls: relaySet.relayUrls, members: new Set(), admins: new Set() };

    const updateMetadata = (e: NDKEvent) => {
        groups.update(groups => {
            let key = groupKey(groupId, relays);
            let entry = groups[key] ?? defaultGroupEntry;
            if (!entry?.metadata || e.created_at! >= entry.metadata?.created_at!) {
                const event = NDKSimpleGroupMetadata.from(e);
                entry.metadata = event;
                entry.name = event.name;
                entry.about = event.about;
                entry.picture = event.picture;
                groups[key] = entry;
                d("☑️ Completed loading metadata for group", {groupId, name: entry.name});
            }
            return groups;
        })
    };

    const updateList = (e: NDKEvent) => {
        const type = e.kind === NDKKind.GroupMembers ? 'membersList' : 'adminsList';
        
        groups.update(groups => {
            const key = groupKey(groupId, relays);
            let entry = groups[key] ?? defaultGroupEntry;
            if (!entry?.[type] || e.created_at! >= entry[type]?.created_at!) {
                const event = NDKSimpleGroupMemberList.from(e);

                entry[type] = event;
                if (type === 'membersList') {
                    entry.members = new Set(event.members);
                } else {
                    entry.admins = new Set(event.members);
                }
                
                groups[key] = entry;
            }
            return groups;
        })
    }

    $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupMetadata], "#d": [groupId] },
    ], { groupable: false, relaySet, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
        onEvent: updateMetadata
    });

    const relayEvents = $ndk.storeSubscribe(filters, {
        subId: 'group-events',
        relaySet,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
        onEvent: ((event: NDKEvent) => {
            if (event.kind === NDKKind.GroupMembers || event.kind === NDKKind.GroupAdmins) updateList(event);
        })
    })

    // relayEvents.subscribe(events => {
    //     groups.update(groups => {
    //         let groupEntry: GroupEntry = { relaySet };

    //         for (const event of events) {
    //             switch (event.kind) {
    //                 case NDKKind.GroupMetadata:
    //                     groupEntry = chooseNewer(groupEntry, 'metadata', event);

    //                     break;
    //             }
    //         }

    //         if (groupEntry.metadata) {
    //             groupEntry.metadata = NDKSimpleGroupMetadata.from(groupEntry.metadata);
    //             groupEntry.name = groupEntry.metadata.name;
    //             groupEntry.about = groupEntry.metadata.about;
    //             groupEntry.picture = groupEntry.metadata.picture
    //             const dTag = groupEntry.metadata.dTag;
    //             d("Metadata for group", {groupId, dTag, name: groupEntry.name});
    //         } else {
    //             d("No metadata for group", {groupId});
    //         }


            
            
    //         groups[key] = groupEntry;
    //         return groups;
    //     });
    // });
}

// function chooseNewer(groupEntry: GroupEntry, key: keyof GroupEntry, event: NDKEvent) {
//     if (!groupEntry[key]) {
//         groupEntry[key] = event as any;
//         return groupEntry;
//     }

//     if (event.created_at! < groupEntry[key].created_at!) {
//         return groupEntry;
//     }

//     groupEntry[key] = event as any;

//     return groupEntry;
// }

export function groupKey(groupId: string, relays: string[]): GroupEntryKey {
    return `${groupId}:${relays.join(',')}`;
}

export function refGroup(
    groupId: string,
    relays: string[]
): GroupEntryKey | undefined {
    const normalizedRelays = relays.map(normalizeRelayUrl)

    if (normalizedRelays.length === 0) return;
    
    const key = groupKey(groupId, normalizedRelays);
    d("Ref group", {groupId, relays, key});
    let currentRef = groupRefs.get(key) ?? 0;
    currentRef++;
    groupRefs.set(key, currentRef);
    d("Current ref", {currentRef});

    if (currentRef === 1) {
        startGroup(groupId, normalizedRelays);
    }

    return key;
}

export function unrefGroup(
    groupId: string,
    relays: string[]
): string | undefined {
    const normalizedRelays = relays.map(normalizeRelayUrl)

    if (normalizedRelays.length === 0) return;

    const key = groupKey(groupId, normalizedRelays);
    let currentRef = groupRefs.get(key) ?? 0;
    currentRef--;
    groupRefs.set(key, currentRef);

    if (currentRef === 0) {
        groupRefs.delete(key);
    }

    return key;
}

export function refGroups(
    tags: NDKTag[]
): Set<GroupEntryKey> {
    d("Ref groups", {tags});
    const keys = new Set<GroupEntryKey>();
    
    for (const tag of tags) {
        const [ type, groupId, ...relays ] = tag;
        if (['h', 'group'].includes(type)) {
            const key = refGroup(groupId, relays);
            if (key) keys.add(key);
        } else {
            d("Tag is not a group", {tag});
        }
    }

    return keys
}

export function unrefGroups(
    tags: NDKTag[]
) {
    for (const tag of tags) {
        const [ type, groupId, ...relays ] = tag;
        if (['h', 'group'].includes(type)) {
            unrefGroup(groupId, relays);
        }
    }
}

export function loadGroups(
    groupTags: NDKTag[]
) {
    
}

export function initGroups() {
    const $ndk = get(ndk);
    const relaySets: Record<string, NDKRelaySet> = {};

    d("Initializing groups");

    groupsList.subscribe($groupsList => {
        if ($groupsList === undefined) return;

        console.log('groupsList', $groupsList.items);

        for (const item of $groupsList.items) {
            const [ tag, groupId, ...relays ] = item;
            if (tag !== 'group' && tag !== 'h') {
                continue;
            }

            if (!startedGroups.has(groupId))
                startGroup(groupId, relays);
        }
    });

    // groups = derived(groupsList, $groupsList => {
    //     const groups: Record<string, NDKSimpleGroup> = {};
    //     if ($groupsList === undefined) return groups;
    //     for (const item of $groupsList.items) {
    //         const [ tag, groupId, ...relays ] = item;
    //         if (tag !== 'group')  continue;

    //         const relayKey = relays.join(',');
    //         if (!relaySets[relayKey]) {
    //             relaySets[relayKey] = NDKRelaySet.fromRelayUrls(relays, $ndk);
    //         }

    //         groups[key] = new NDKSimpleGroup($ndk, relaySets[relayKey], groupId);
    //     }

    //     return groups;
    // })
}