<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKArticle, NDKEvent, NDKFilter, NDKKind, NDKRelaySet, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKVideo, NDKWiki } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { deriveStore } from "$utils/events/derive";
	import { Readable, writable } from "svelte/store";
	import { onDestroy, onMount } from 'svelte';
	import { Group } from '.';

    export let groupId: string;
    export let relays: string[];

    export let skipFooter: boolean = false;

    const dFilter: NDKFilter = { "#d": [groupId] };

    const relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk, true);

    const hFilter: NDKFilter = { "#h": [groupId] };
    const contentFilters: NDKFilter[] = [
        { kinds: [ NDKKind.Text, NDKKind.GroupNote, NDKKind.GroupReply ], ...hFilter, limit: 50 },
        { kinds: [ NDKKind.GroupChat ], ...hFilter, limit: 50 },
        { kinds: [ NDKKind.Article ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.Wiki ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], ...hFilter, limit: 10 },
        { kinds: [ NDKKind.Highlight ], ...hFilter, limit: 100 },
        { kinds: [ NDKKind.TierList, NDKKind.PinList ], ...hFilter },
        { kinds: [ NDKKind.SubscriptionTier ], ...hFilter },
    ];

    function onEvent(event: NDKEvent) {
        group.update($group => {
            if (event.kind === NDKKind.GroupMetadata) {
                $group.metadata = NDKSimpleGroupMetadata.from(event);
                $group.name = $group.metadata.name;
                $group.picture = $group.metadata.picture;
                $group.about = $group.metadata.about;
            } else if (event.kind === NDKKind.GroupAdmins) {
                $group.admins = NDKSimpleGroupMemberList.from(event);
                if ($currentUser)
                    $group.isAdmin = $group.admins.hasMember($currentUser.pubkey);
                else
                    $group.isAdmin = false;
            } else if (event.kind === NDKKind.GroupMembers) {
                $group.members = NDKSimpleGroupMemberList.from(event);
                if ($currentUser)
                    $group.isMember = $group.members.hasMember($currentUser.pubkey);
                else
                    $group.isMember = false;
            }

            return $group;
        })
    }
    
    export let group = writable<Group>({
        id: groupId,
        relayUrls: relays, relaySet,
        events: $ndk.storeSubscribe([
            { kinds: [ NDKKind.GroupMetadata, NDKKind.GroupAdmins, NDKKind.GroupMembers ], ...dFilter },
        ], { subId: 'group-events', relaySet, autoStart: false, onEvent }),
        content: $ndk.storeSubscribe(contentFilters, { subId: 'group-content', relaySet, autoStart: false }),
    });

    onMount(() => {
        $group.events.startSubscription();
        $group.content.startSubscription();

        // Subscriptions
        // const events = $ndk.storeSubscribe(filters, { subId: 'group-events', groupable: false, relaySet: $group.relaySet });
        // group.events = events;
        articles = deriveStore($group.content, NDKArticle);
        videos = deriveStore($group.content, NDKVideo);
        wiki = deriveStore($group.content, NDKWiki);
        notes = deriveStore<NDKEvent>($group.content, undefined, [ NDKKind.GroupNote, NDKKind.GroupReply, NDKKind.Text ]);
        chat = deriveStore<NDKEvent>($group.content, undefined, [ NDKKind.GroupChat ]);
        tiers = deriveStore($group.content, NDKSubscriptionTier);
    });

    let articles: Readable<NDKArticle[]>;
    let videos: Readable<NDKVideo[]>;
    let wiki: Readable<NDKWiki[]>;
    let notes: Readable<NDKEvent[]>;
    let chat: Readable<NDKEvent[]>;
    let tiers: Readable<NDKSubscriptionTier[]>;

    onDestroy(() => {
        $group.events?.unsubscribe();
        $group.content?.unsubscribe();
    });
</script>

{#if $group.metadata}
    <slot
        {group}
        {articles}
        {videos}
        {wiki}
        {notes}
        {chat}
        {tiers}
    />
{:else}
{/if}