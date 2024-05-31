<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { detailView, resetLayout } from "$stores/layout";
	import { getAuthorUrlSync } from "$utils/url";
	import ItemShell from "$views/ItemShell.svelte";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { title } from "../../[id]/[tagId]/store";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { eventToKind } from "$utils/event";
	import { appMobileHideNewPostButton } from "$stores/app";

    let id: string;
    let event: NDKEvent | NDKArticle | NDKList | NDKVideo | undefined | null;
    let image = $page.data.image;

    if ($page.data.event) {
        try {
            event = new NDKEvent($ndk, $page.data.event);
            if (event) event = eventToKind(event);
        } catch {}
    }

    $detailView = null;
    $appMobileHideNewPostButton = true;
    
    $: if (id !== $page.params.id) {
        id = $page.params.id;

        $ndk.fetchEvent(id).then((e) => {
            event = e ? eventToKind(e) : null;
        });
    }

    $: if (event) {
        const author = event.author;

        if (event.kind === event.dTag) {
            const authorUrl = getAuthorUrlSync(author);
            goto(`${authorUrl}/${event.dTag}`);
        }
    }

    onDestroy(resetLayout);
</script>

<svelte:head>
    {#if event instanceof NDKArticle}
        <title>{event.title}</title>
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