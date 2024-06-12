<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { resetLayout } from "$stores/layout";
	import ItemShell from "$views/ItemShell.svelte";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { appMobileHideNewPostButton } from "$stores/app";
	import { loadedEvent, title } from "$stores/item-view";

    let image = $page.data.image;

    let event;
    $: event = $loadedEvent;

    $appMobileHideNewPostButton = true;
    
    onDestroy(resetLayout);
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

<LoadingScreen ready={event !== undefined}>
    {#if event}
        <ItemShell {event} title={$title}>
            <ItemView {event}  />
        </ItemShell>
    {/if}
</LoadingScreen>