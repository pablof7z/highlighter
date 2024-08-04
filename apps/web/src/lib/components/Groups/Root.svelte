<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKArticle, NDKEvent, NDKFilter, NDKKind, NDKList, NDKRelayAuthPolicies, NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKVideo, NDKWiki } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { deriveListStore, deriveStore } from "$utils/events/derive";
	import { derived } from "svelte/store";
	import { onDestroy, onMount } from 'svelte';
	import { ContentStores } from '.';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { Readable } from 'svelte/store';

    export let groupId: string | undefined = undefined;
    export let relays: string[] | undefined = undefined;
    export let skipFooter: boolean = false;

    groupId ??= "";

    const hFilter: NDKFilter = { "#h": [groupId] };
    const dFilter: NDKFilter = { "#d": [groupId] };

    const relaySet = NDKRelaySet.fromRelayUrls(relays||[], $ndk, false);
    // relaySet.relays.forEach((r) => r.authPolicy = NDKRelayAuthPolicies

    export let group: NDKSimpleGroup | undefined = undefined;
    group ??= new NDKSimpleGroup($ndk, relaySet, groupId);

    const filters: NDKFilter[] = [
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
    ];

    let events: NDKEventStore<NDKEvent> | undefined = undefined;

    onMount(() => {
        // Subscriptions
        events = $ndk.storeSubscribe(filters, { subId: 'group-events', groupable: false, relaySet: group.relaySet });
        metadata = deriveListStore(events, NDKSimpleGroupMetadata);
        admins = deriveListStore(events, NDKSimpleGroupMemberList, [NDKKind.GroupAdmins]);
        members = deriveListStore(events, NDKSimpleGroupMemberList);
        articles = deriveStore(events, NDKArticle);
        videos = deriveStore(events, NDKVideo);
        wiki = deriveStore(events, NDKWiki);
        notes = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupNote, NDKKind.GroupReply, NDKKind.Text ]);
        chat = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupChat ]);
        tiers = deriveStore(events, NDKSubscriptionTier);
        joinRequests = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupAdminRequestJoin ]);
        isAdmin = derived(
            [ currentUser, admins ], ([ $currentUser, $admins ]) => {
                if ($currentUser && $admins) {
                    return $admins.hasMember($currentUser.pubkey);
                }
                return false;
            }
        );
        isMember = derived([ currentUser, members, admins ], ([ $currentUser, $members, $admins ]) => {
            if ($currentUser && $members && $admins) {
                return $members.hasMember($currentUser.pubkey) || $admins.hasMember($currentUser.pubkey);
            }
            return false;
        });

        stores = {
            articles,
            wiki,
            videos,
            notes,
            chat
        };
    });

    onDestroy(() => {
        events?.unsubscribe();
    });

    // Derivations
    let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    let admins: Readable<NDKSimpleGroupMemberList | undefined>;
    let members: Readable<NDKSimpleGroupMemberList | undefined>;
    let articles: Readable<NDKArticle[]>;
    let videos: Readable<NDKVideo[]>;
    let wiki: Readable<NDKWiki[]>;
    let notes: Readable<NDKEvent[]>;
    let chat: Readable<NDKEvent[]>;
    let tiers: Readable<NDKSubscriptionTier[]>;
    let joinRequests: Readable<NDKEvent[]>;
    let isAdmin: Readable<boolean>;
    let isMember: Readable<boolean>;

    let stores: ContentStores;
</script>

{#if $metadata}
    <slot
        {group}
        {metadata}
        {admins}
        {members}
        {isAdmin}
        {isMember}
        {joinRequests}
        {tiers}
        {stores}
    />
{/if}