<script lang="ts">
	import { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
	import { articleKinds, isEventFullVersion } from "$utils/event";
	import { onDestroy } from "svelte";
	import { layout, pageHeader } from "$stores/layout";
	import ItemHeader from "$components/ItemHeader.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import Whoops from "$components/PageElements/Whoops.svelte";
	import EmbeddedEventWrapper from "$components/Events/EmbeddedEventWrapper.svelte";
	import { ndk } from "$stores/ndk";
	import { page } from "$app/stores";
	import Highlight from "$components/Highlight.svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";

    export let event: NDKEvent | NDKArticle | NDKVideo;
    export let ignoreHeader: boolean = false;

    let image = $page.data.image;
    let article: NDKArticle;

    $: if (articleKinds.includes(event.kind)) {
        article = NDKArticle.from(event);
        image ??= article?.image;
    }

    $: if (!ignoreHeader) {
        if (event) {
            $layout.header = {
                component: ItemHeader,
                props: {
                    item: event,
                    class: "max-w-[var(--content-focused-width)] mx-auto w-full"
                }
            }
        }
    }

    onDestroy(() => {
        if (!ignoreHeader && $pageHeader?.component)
            $pageHeader.component = undefined;
    })
</script>

<svelte:head>
    {#if article instanceof NDKArticle}
        <meta property="og:title" content={article.title} />
        <meta property="og:type" content="article" />
        <meta property="twitter:card" content="summary_large_image" />
        <meta property="twitter:title" content={article.title} />

        {#if article?.summary}
            <meta name="description" content={article.summary} />
            <meta property="og:description" content={article.summary} />
            <meta property="twitter:description" content={article.summary} />
        {/if}
    {:else}
        event is not article
    {/if}

    {#if image}
        <meta property="og:image" content={image} />
        <meta property="twitter:image" content={image} />
    {/if}
</svelte:head>

{#if articleKinds.includes(event.kind)}
{:else if event instanceof NDKVideo}
{:else if !event}
    <Whoops message="Event has not been provided" devMessage="<ItemView /> component requires an event prop" />
{:else if event.kind === NDKKind.Text}
    <div class="discussion-wrapper">
        <EventWrapper
            {event}
            expandThread={true}
            expandReplies={true}
            class="text-lg rounded"
        >
            <EventContent
                ndk={$ndk}
                {event}
                eventCardComponent={EmbeddedEventWrapper}
                class="text-foreground"
            />
        </EventWrapper>
    </div>
{:else if event.kind === 33889}
    <ScrollArea class="whitespace-nowrap border-y border-border p-4" orientation="horizontal">
        <div class="w-max flex flex-nowrap">
            {#each event.getMatchingTags("pin") as pin}
                <img src={pin[1]} class="object-fit w-auto h-full max-h-screen" />
            {/each}
        </div>
    </ScrollArea>
{:else if event.kind === NDKKind.Highlight}
    <Highlight highlight={NDKHighlight.from(event)} expandReplies compact />
{:else}
    <EventWrapper {event} class="bg-foreground/10 p-6 rounded" />
{/if}
