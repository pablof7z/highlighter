import { ndk } from '$stores/ndk';
import currentUser from '$stores/currentUser';
import { NDKList, NDKTag, NDKEvent, NDKKind, NDKRelaySet, NDKSimpleGroupMetadata, NDKSimpleGroupMemberList, NDKSubscriptionTier } from '@nostr-dev-kit/ndk';
import { writable, get, type Readable, type Writable } from 'svelte/store';
import { GroupData } from '.';

export function loadGroupDataFromList(
    list: Readable<NDKList>
): Writable<Record<string, GroupData>> {
    const loaded = new Set<string>();
    const validTags = new Set(["h", "group"]);
    const store = writable<Record<string, GroupData>>({});

    function filterNewTags(tags: NDKTag[]): NDKTag[] {
        return tags.filter(tag => {
            const [type, id] = tag;
            return validTags.has(type) && !loaded.has(id);
        });
    }

    function updateStoreWithGroups(groups: Record<string, GroupData>) {
        store.update(currentGroups => {
            for (const id in groups) {
                currentGroups[id] = groups[id];
                loaded.add(id);
            }
            return currentGroups;
        });
    }

    list.subscribe($list => {
        const tagsToLoad = filterNewTags($list.tags);
        if (tagsToLoad.length === 0) return;

        const groupData$ = loadGroupsData(tagsToLoad);
        groupData$.subscribe(updateStoreWithGroups);
    });

    return store;
}

export function loadGroupsData(
    tags: NDKTag[],
): Writable<Record<string, GroupData>> {
    const store = writable<Record<string, GroupData>>({});
    const relayMap = new Map<string, string[]>();
    const groupMap = new Map<string, string[]>();
    const relaysToGroupMap = createRelayToGroupMap(tags);
    const $ndk = get(ndk);
    const $currentUser = get(currentUser);

    function createRelayToGroupMap(tags: NDKTag[]): Map<string, string[]> {
        tags.forEach(([type, id, ...relays]) => {
            groupMap.set(id, relays);

            relays.forEach(relay => {
                if (!relayMap.has(relay)) {
                    relayMap.set(relay, []);
                }
                relayMap.get(relay)!.push(id);
            });
        });

        return relayMap;
    }

    function getPropertyType(event: NDKEvent): 'metadata' | 'admins' | 'members' | "tiers" | undefined {
        switch (event.kind) {
            case NDKKind.GroupMetadata: return "metadata";
            case NDKKind.GroupAdmins: return "admins";
            case NDKKind.GroupMembers: return "members";
            case NDKKind.SubscriptionTier: return "tiers";
        }
    }

    function getGroupId(event: NDKEvent) {
        switch (event.kind) {
            case NDKKind.GroupMetadata:
            case NDKKind.GroupAdmins:
            case NDKKind.GroupMembers: return event.tagValue("d");
            case NDKKind.SubscriptionTier: return event.tagValue("h");
        }
        throw new Error('unknown event kind ' + event.kind);
    }

    function handleEvent(event: NDKEvent) {
        const groupId = getGroupId(event);
        if (!groupId) return;

        store.update($groups => {
            const propertyType = getPropertyType(event);

            if ($groups[groupId]) {
                if (propertyType && propertyType !== "tiers") {
                    const existingProperty = $groups[groupId][propertyType];
                    if (existingProperty?.created_at && existingProperty.created_at > event.created_at!) {
                        return $groups;
                    }
                }
            } else {
                $groups[groupId] = createEmptyGroupData(groupId, groupMap.get(groupId) || []);
            }

            updateGroupData($groups[groupId], event, propertyType);
            return $groups;
        });

        // update isMember and isAdmin for currentUser
        currentUser.subscribe($currentUser => {
            store.update($groups => {
                for (const [groupId, groupData] of Object.entries($groups)) {
                    if ($currentUser) {
                        groupData.isAdmin = groupData.admins?.members.includes($currentUser.pubkey);
                        groupData.isMember = groupData.members?.members.includes($currentUser.pubkey);
                    } else {
                        groupData.isAdmin = false;
                        groupData.isMember = false;
                    }
                    $groups[groupId] = groupData;
                }
                return $groups;
            });
        });
    }

    const createEmptyGroupData = (id: string, relays: string[]): Partial<GroupData> => { return {
        id,
        relayUrls: relays,
        relaySet: NDKRelaySet.fromRelayUrls(relays, $ndk),
    } }

    function updateGroupData(groupData: GroupData, event: NDKEvent, propertyType: string | undefined) {
        switch (propertyType) {
            case "metadata":
                groupData.metadata = NDKSimpleGroupMetadata.from(event);
                groupData.name = groupData.metadata.name;
                groupData.picture = groupData.metadata.picture;
                groupData.about = groupData.metadata.about;
                groupData.access = groupData.metadata.access;
                break;
            case "admins":
                groupData.admins = NDKSimpleGroupMemberList.from(event);
                if ($currentUser) {
                    groupData.isAdmin = groupData.admins.hasMember($currentUser.pubkey);
                }
                break;
            case "members":
                groupData.members = NDKSimpleGroupMemberList.from(event);
                if ($currentUser) {
                    groupData.isMember = groupData.members.hasMember($currentUser.pubkey);
                }
                break;
            case "tiers":
                if (!groupData.tiers) {
                    groupData.tiers = [];
                }
                if (!groupData.tiers.some(tier => tier.id === event.id)) {
                    groupData.tiers.push(NDKSubscriptionTier.from(event));
                }
                break;
        }
    }

    function setupSubscriptions() {
        for (const [relay, groupIds] of relaysToGroupMap) {
            const relaySet = NDKRelaySet.fromRelayUrls([relay], $ndk);
            const sub = $ndk.subscribe([
                { kinds: [NDKKind.GroupMetadata, NDKKind.GroupAdmins, NDKKind.GroupMembers], "#d": groupIds },
                { kinds: [NDKKind.SubscriptionTier], "#h": groupIds }
            ], { groupable: false, subId: 'group-data', closeOnEose: true }, relaySet, false);
            sub.on("event", handleEvent);
            sub.start();
        }
    }

    setupSubscriptions();

    return store;
}