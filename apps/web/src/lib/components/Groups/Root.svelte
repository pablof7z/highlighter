<script lang="ts">
	import { NDKArticle, NDKEvent, NDKFilter, NDKKind, NDKRelaySet, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKVideo, NDKWiki } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { deriveStore } from "$utils/events/derive";
	import { derived, Readable, Writable, writable } from "svelte/store";
	import { onDestroy, onMount } from 'svelte';
	import * as Groups from '.';

    export let groupId: string;
    export let relays: string[];

    export let skipFooter: boolean = false;

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
        { kinds: [ NDKKind.PinList ], ...hFilter },
    ];

    export let groups: Writable<Record<string, Groups.GroupData>> = undefined;
    export let group: Readable<Groups.GroupData> | undefined = undefined;

    const events = $ndk.storeSubscribe(contentFilters, { subId: 'group-content', relaySet, autoStart: false });

    onMount(() => {
        groups = Groups.loadGroupsData([["group", groupId, ...relays]]);
        group = derived(groups, $groups => $groups[groupId]);
        events.startSubscription();
        articles = deriveStore(events, NDKArticle);
        videos = deriveStore(events, NDKVideo);
        wiki = deriveStore(events, NDKWiki);
        notes = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupNote, NDKKind.GroupReply, NDKKind.Text ]);
        chat = deriveStore<NDKEvent>(events, undefined, [ NDKKind.GroupChat ]);
    });

    export let articles: Readable<NDKArticle[]> | undefined = undefined;
    export let videos: Readable<NDKVideo[]> | undefined = undefined;
    export let wiki: Readable<NDKWiki[]> | undefined = undefined;
    export let notes: Readable<NDKEvent[]> | undefined = undefined;
    export let chat: Readable<NDKEvent[]> | undefined = undefined;

    onDestroy(() => {
        $group?.events?.unsubscribe();
        events?.unsubscribe();
    });
</script>

{#if $group && $group.metadata && $group.members}
    <slot
        {group}
        {articles}
        {videos}
        {wiki}
        {notes}
        {chat}
    />
{/if}