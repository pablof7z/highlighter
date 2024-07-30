<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKArticle, NDKEvent, NDKFilter, NDKKind, NDKRelayAuthPolicies, NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKVideo, NDKWiki } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { deriveListStore, deriveStore } from "$utils/events/derive";
	import { derived } from "svelte/store";
	import { onDestroy } from 'svelte';
	import { ContentStores } from '.';

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

    const relaySet = NDKRelaySet.fromRelayUrls(relays||[], $ndk, false);
    // relaySet.relays.forEach((r) => r.authPolicy = NDKRelayAuthPolicies

    const group = new NDKSimpleGroup($ndk, relaySet, groupId);

    // Subscriptions
    const events = $ndk.storeSubscribe([
        { kinds: [ NDKKind.GroupNote, NDKKind.GroupReply ], ...hFilter, limit: 50 },
        { kinds: [ NDKKind.GroupChat ], ...hFilter, limit: 50 },
        { kinds: [ NDKKind.Article ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.Wiki ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], ...hFilter, limit: 10 },
        { kinds: [ NDKKind.Highlight ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.TierList, NDKKind.PinList ], ...hFilter },
        { kinds: [ NDKKind.SubscriptionTier ], ...hFilter },
        { kinds: [ NDKKind.GroupMetadata, NDKKind.GroupAdmins, NDKKind.GroupMembers ], ...dFilter },
    ], { subId: 'group-events', groupable: false, relaySet });
    
    relaySet.relays.forEach((r) => {
        r.on("authed", () => {
            events.unsubscribe();
            events.startSubscription();
        });
    });

    onDestroy(() => {
        events.unsubscribe();
    });

    // const events2 = $ndk.storeSubscribe([
    //     { kinds: [ NDKKind.SubscriptionTier ], ...hFilter, limit: 100 },
    // ], { subId: 'group-events-2', groupable: false, relaySet });

    // Derivations
    const metadata = deriveListStore(events, NDKSimpleGroupMetadata);
    const admins = deriveListStore(events, NDKSimpleGroupMemberList, [NDKKind.GroupAdmins]);
    const members = deriveListStore(events, NDKSimpleGroupMemberList);
    const articles = deriveStore(events, NDKArticle);
    const videos = deriveStore(events, NDKVideo);
    const wiki = deriveStore(events, NDKWiki);
    const notes = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupNote, NDKKind.GroupReply, NDKKind.Text ]);
    const chat = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupChat ]);
    const tiers = deriveStore(events, NDKSubscriptionTier);
    
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
            console.log("isMember", {currentUser: $currentUser, members: $members, admins: $admins})
            if ($currentUser && $members && $admins) {
                return $members.hasMember($currentUser.pubkey) || $admins.hasMember($currentUser.pubkey);
            }
            return false;
        }
    );

    const stores: ContentStores = {
        articles,
        wiki,
        videos,
        notes,
        chat
    };
</script>

{#if $metadata}
    <slot
        {group}
        {metadata}
        {admins}
        {members}
        {isAdmin}
        {isMember}
        {tiers}
        {stores}
    />
{:else}
    loading
{/if}