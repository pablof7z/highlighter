<script lang="ts">
	import { NDKNutzap } from '@nostr-dev-kit/ndk';
	import { deriveStore } from '$utils/events/derive';
	import { derived, Readable } from 'svelte/store';
	import { NavigationOption } from './../../../app.d.js';
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { lastSeenTimestamp, notifications } from '$stores/notifications';
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { onDestroy, onMount } from 'svelte';
	import { layout } from "$stores/layout";
	import { Navigation } from "$utils/navigation";
	import { roundedItemCount } from '$utils/numbers.js';

    let timeout: any;

    $layout.sidebar = false;
    $layout.navigation = false;

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

    const zaps = derived(notifications, $notifications => 
        $notifications?.filter(notification => [ NDKKind.Zap, NDKKind.Nutzap].includes(notification.kind!))
    );
    const replies = derived(notifications, $notifications => 
        $notifications?.filter(notification => [ NDKKind.Text, NDKKind.GroupReply].includes(notification.kind!))
    );

    let selectedStore: Readable<NDKEvent[]> = notifications;

    const optionManager = new Navigation();
    let options: NavigationOption[] = [];
    optionManager.options.subscribe(value => $layout.navigation = value);

    optionManager.setOption('all', { name: "All", badge: roundedItemCount($notifications!), fn: () => selectedStore = notifications }, true);

    optionManager.setOption('replies', { name: "Replies", badge: roundedItemCount($replies!), fn: () => selectedStore = replies }, true);
    optionManager.setOption('zaps', { name: "Zaps", badge: roundedItemCount($zaps!), fn: () => selectedStore = zaps }, true);
</script>

{#if notifications && $notifications}
{#key selectedStore}
    <StoreFeed
        feed={selectedStore}
        renderAsIs
        on:click
    />
{/key}
{/if}
