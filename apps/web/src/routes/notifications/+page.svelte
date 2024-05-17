<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { lastSeenTimestamp } from '$stores/notifications';
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { ndk } from '@kind0/ui-common';
	import { derived } from 'svelte/store';
	import { onDestroy, onMount } from 'svelte';

    let timeout: any;

    let originalLastSeenTimestamp = $lastSeenTimestamp;

    onMount(() => {
        setTimeout(() => {
            $lastSeenTimestamp = Math.floor(new Date().getTime() / 1000);
            timeout = undefined;
        }, 0);
    })

    onDestroy(() => {
        if (timeout) clearTimeout(timeout);
    })

    const filters: NDKFilter[] = [
        {
            kinds: [NDKKind.Highlight, NDKKind.Text, NDKKind.Article, NDKKind.HorizontalVideo],
            "#p": [$currentUser!.pubkey],
            limit: 100
        }
    ]

    export let feed = $ndk.storeSubscribe(filters);

    let showEventsOlderThan: Date | undefined = undefined;

    feed.onEose(() => {
        showEventsOlderThan = new Date();
    });

    const unreadNotifications = derived(feed, $feed => {
        if (!originalLastSeenTimestamp) return $feed;
        else return $feed.filter(event => event.created_at! > originalLastSeenTimestamp);
    });

    const readNotifications = derived(feed, $feed => {
        if (!originalLastSeenTimestamp) return [];
        else return $feed.filter(event => event.created_at! <= originalLastSeenTimestamp);
    });
</script>

{#if $unreadNotifications.length > 0}
    <StoreFeed
        feed={unreadNotifications}
        bind:showEventsOlderThan
        on:click
    />
    {#if $readNotifications.length > 0}
        <div class="divider divider-base-300 text-xs text-base-300-content">READ NOTIFICATIONS</div>
    {/if}
{/if}

{#if $readNotifications.length > 0}
    <StoreFeed
        feed={readNotifications}
        bind:showEventsOlderThan
        on:click
    />
{/if}
