<script lang="ts">
    import SubscriptionListItem from "$components/Subscriptions/SubscriptionListItem.svelte";
	import { pageHeader } from "$stores/layout";
	import { NDKKind, NDKSubscriptionStart } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { ndk } from "$stores/ndk";
	import currentUser from "$stores/currentUser";

	$pageHeader = {
		title: "Subscriptions",
		left: {
			label: "Back",
			url: "/settings",
		}
	};

    const subscriptionStart: NDKEventStore<NDKSubscriptionStart> = $ndk.storeSubscribe({
        kinds: [ NDKKind.Subscribe ],
        authors: [$currentUser.pubkey],
    }, { groupable: false, subId: "subscriptions" }, NDKSubscriptionStart)

    onDestroy(() => subscriptionStart.unsubscribe())
</script>

    {#each $subscriptionStart as event}
        <SubscriptionListItem subsciptionStart={event} />
    {/each}