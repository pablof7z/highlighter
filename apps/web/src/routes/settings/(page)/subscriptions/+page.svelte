<script lang="ts">
    import SubscriptionListItem from "$components/Subscriptions/SubscriptionListItem.svelte";
	import { pageHeader, pageSidebar } from "$stores/layout";
	import { ndk, user } from '@kind0/ui-common';
	import { NDKKind, NDKSubscriptionStart } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';

	$pageHeader = {
		title: "Subscriptions",
		left: {
			label: "Back",
			url: "/settings",
		}
	};

    const subscriptionStart: NDKEventStore<NDKSubscriptionStart> = $ndk.storeSubscribe({
        kinds: [ NDKKind.Subscribe ],
        authors: [$user.pubkey],
    }, { groupable: false, subId: "subscriptions" }, NDKSubscriptionStart)

    onDestroy(() => subscriptionStart.unsubscribe())
</script>

    {#each $subscriptionStart as event}
        <SubscriptionListItem subsciptionStart={event} />
    {/each}