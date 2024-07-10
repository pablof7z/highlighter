<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { lastSeenTimestamp, notifications } from '$stores/notifications';
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
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
</script>

{#if notifications && $notifications}
    <StoreFeed
        feed={notifications}
        renderAsIs
        on:click
    />
{/if}
