<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKArticle, NDKFilter, NDKKind, NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { deriveListStore, deriveStore } from "$utils/events/derive";
	import { derived } from "svelte/store";

    export let tag: NDKTag | undefined = undefined;
    export let groupId: string | undefined = undefined;
    export let relays: string[] | undefined = undefined;
    export let skipFooter: boolean = false;

    if (tag) {
        groupId = tag[1];
        relays = tag.slice(2, tag.length);
    }

    groupId ??= "";

    const hFilter: NDKFilter = { "#h": [groupId] };
    const dFilter: NDKFilter = { "#d": [groupId] };

    const relaySet = NDKRelaySet.fromRelayUrls(relays||[], $ndk);

    const group = new NDKSimpleGroup($ndk, relaySet, groupId);

    // Subscriptions
    const events = $ndk.storeSubscribe([
        { kinds: [ NDKKind.GroupNote, NDKKind.GroupReply ], ...hFilter, limit: 50 },
        { kinds: [ NDKKind.Article ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.Wiki ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], ...hFilter, limit: 10 },
        { kinds: [ NDKKind.Highlight ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.TierList, NDKKind.PinList ], ...hFilter },
        { kinds: [ NDKKind.GroupMetadata, NDKKind.GroupAdmins, NDKKind.GroupMembers ], ...dFilter },
    ], { subId: 'group-events', groupable: false, relaySet });

    const events2 = $ndk.storeSubscribe([
        { kinds: [ NDKKind.SubscriptionTier ], ...hFilter, limit: 100 },
    ], { subId: 'group-events-2', groupable: false, relaySet });

    // Derivations
    const metadata = deriveListStore(events, NDKSimpleGroupMetadata);
    const admins = deriveListStore(events, NDKSimpleGroupMemberList, [NDKKind.GroupAdmins]);
    const members = deriveListStore(events, NDKSimpleGroupMemberList);
    const tiers = deriveStore(events2, NDKSubscriptionTier);
    const articles = deriveStore(events, NDKArticle);

    $: {
        group.metadata = $metadata;
        console.log("assigning group metadata", {groupId, metadata: $metadata?.tags})
    }
    
    const isAdmin = derived(
        [ currentUser, admins ], ([ $currentUser, $admins ]) => {
            if ($currentUser && $admins) {
                return $admins.hasMember($currentUser.pubkey);
            }
            return false;
        }
    );
    const isMember = derived(
        [ currentUser, members, admins ], ([ $currentUser, $members, $admins ]) => {
            if ($currentUser && $members && $admins) {
                return $members.hasMember($currentUser.pubkey) || $admins.hasMember($currentUser.pubkey);
            }
            return false;
        }
    );
</script>

<slot
    {group}
    {metadata}
    {admins}
    {articles}
    {members}
    {isAdmin}
    {isMember}
    {tiers}
/>