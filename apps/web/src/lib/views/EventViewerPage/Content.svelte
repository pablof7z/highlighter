<script lang="ts">
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { appMobileHideNewPostButton } from "$stores/app";
	import { ndk } from "$stores/ndk";
	import ItemShell from "$views/ItemShell.svelte";
    import { NDKArticle, NDKEvent, NDKVideo, filterFromId } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { afterUpdate } from "svelte";
	import { EventType } from "../../../app";

    export let eventId: string;
    export let type: EventType | string | undefined = undefined;

    $appMobileHideNewPostButton = true;

    let event: NDKEvent | NDKArticle | NDKVideo;

    let eventStore: NDKEventStore<NDKEvent>;
    let loading = false;
    let eosed = false;
    let title: string | undefined;
    let image: string | undefined;
        
    afterUpdate(() => {
        const filter = filterFromId(eventId);
        eventStore = $ndk.storeSubscribe(filter, { subId: 'event-viewer', closeOnEose: true, groupable: false });
        eventStore.onEose(() => { eosed = true; });
        
        // if we are still loading after 1 second, show the loading screen
        setTimeout(() => { loading = true; }, 1000);
    });

    $: if (event) {
        if (event instanceof NDKArticle) {
            type = "article";
            image = event.image;
            title = event.title;
        } else if (event instanceof NDKVideo) {
            type = "video";
            image = event.thumbnail;
            title = event.title;
        } else {
            type = "event";
            image = undefined;
        }
    }
</script>

<svelte:head>
    {#if event instanceof NDKArticle}
        <meta property="og:title" content={event.title} />
        <meta property="og:type" content="article" />
        <meta property="twitter:card" content="summary_large_image" />
        <meta property="twitter:title" content={event.title} />

        {#if event?.summary}
            <meta name="description" content={event.summary} />
            <meta property="og:description" content={event.summary} />
            <meta property="twitter:description" content={event.summary} />
        {/if}
    {/if}

    {#if image}
        <meta property="og:image" content={image} />
        <meta property="twitter:image" content={image} />
    {/if}
</svelte:head>

{#if event}
    <ItemShell {event} {title}>
        <ItemView {event}  />
    </ItemShell>
{:else if eosed}
    <p>Unable to find the event.</p>
{:else if loading}
    <p>Still looking for the event...</p>
{/if}