<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { lastSeenTimestamp, notifications } from '$stores/notifications';
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { ndk } from "$stores/ndk";
	import { derived } from 'svelte/store';
	import { onDestroy, onMount } from 'svelte';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import Name from '$components/User/Name.svelte';

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
