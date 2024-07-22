<script lang="ts">
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
import { wotFiltered, wotFilteredStore } from "$stores/wot";
	import { mainContentKinds } from "$utils/event";
	import { ndk } from "$stores/ndk.js";

    export let topic: string;

    const events = $ndk.storeSubscribe({
        kinds: [1, ...mainContentKinds],
        "#t": [topic]
    });

    const filteredEvents = wotFilteredStore(events);
</script>

<svelte:head>
    <title>{topic}</title>
</svelte:head>

<!-- <ComplexHeaderWithBanner
    user={$currentUser}
    image={`https://picsum.photos/800/600?random=${encodeURIComponent(topic)}`}
> -->
    <h1>{topic}</h1>

<StoreFeed
    feed={filteredEvents}
/>
<!-- </ComplexHeaderWithBanner> -->