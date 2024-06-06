<script lang="ts">
	import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
	import { isEventFullVersion } from "$utils/event";
	import ArticleView from "$components/ArticleView.svelte";
	import { onDestroy, onMount } from "svelte";
	import { pageHeader } from "$stores/layout";
	import ItemHeader from "$components/ItemHeader.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import Whoops from "$components/PageElements/Whoops.svelte";
	import ListShell from "$views/List/ListShell.svelte";
	import VideoView from "./VideoView.svelte";
	import EmbeddedEventWrapper from "$components/Events/EmbeddedEventWrapper.svelte";
	import { ndk } from "$stores/ndk";

    export let event: NDKEvent;
    export let ignoreHeader: boolean = false;

    if (!ignoreHeader) {
        $pageHeader ??= {};
        $: $pageHeader.component = ItemHeader;
        $: $pageHeader.props = {
            item: event,
            class: "max-w-[var(--content-focused-width)] mx-auto w-full"
        }
    }

    onDestroy(() => {
        if (!ignoreHeader && $pageHeader?.component)
            $pageHeader.component = undefined;
    })

</script>

{#if event instanceof NDKArticle}
    <ArticleView
        article={event}
        isFullVersion={isEventFullVersion(event)}
    />
{:else if event instanceof NDKVideo}
    <VideoView
        video={event}
        isFullVersion={isEventFullVersion(event)}
    />
{:else if !event}
    <Whoops message="Event has not been provided" devMessage="<ItemView /> component requires an event prop" />
{:else if event.kind === NDKKind.ArticleCurationSet}
    <ListShell list={NDKList.from(event)} />
{:else if event.kind === NDKKind.Text}
    <div class="discussion-wrapper">
        <EventWrapper
            {event}
            expandThread={true}
            expandReplies={true}
            class="text-lg p-6 rounded"
        >
            <EventContent
                ndk={$ndk}
                {event}
                eventCardComponent={EmbeddedEventWrapper}
            />
        </EventWrapper>
    </div>
{:else}
    <EventWrapper {event} class="bg-foreground/10 p-6 rounded">
        <EventContent ndk={$ndk} {event} class="highlight" eventCardComponent={EmbeddedEventWrapper} />
    </EventWrapper>
{/if}

    <!-- {#if event && eventType}
        {#if eventType === "article" && article}
            
            <MoreFromUser user={event.author} />
        {:else if eventType === "video" && video}
            <div class="flex-col justify-start items-start gap-8 flex {mxClass} max-w-3xl py-6">
                <VideoView
                    {video}
                    {isFullVersion}
                />
            </div>
        {:else if ["group-note"].includes(eventType)}
            <div class="flex-col justify-start items-start gap-8 flex {mxClass} max-w-3xl">
                <div class="w-full flex items-center flex-col justify-center">
                    <div class="w-full">
                        <FeedGroupPost {event} class="bg-foreground/10 rounded p-6" />
                    </div>
                </div>

                <div class="divider my-0"></div> -->
<!-- 
                <EventResponses {event} /> -->
<!--
            </div>
        {:else if ["short-note"].includes(eventType)}
            <HighlightingArea>
                <EventWrapper
                    {event}
                    
                />
                
            </HighlightingArea>
        {:else if eventType === 'curation'}
            <ListView {event} {urlPrefix} {authorUrl} />
        {:else if eventType === 'highlight'}
                <div class="max-w-2xl mx-auto w-full">
                    <Highlight highlight={NDKHighlight.from(event)} {urlPrefix} {authorUrl} />
                </div>
        {:else}
            <CreatorShell user={event.author}>
                <div class="{mxClass} max-w-3xl">
                    <EventWrapper {event} class="bg-foreground/10 p-6 rounded">
                        <EventContent ndk={$ndk} {event} class="prose highlight" />
                    </EventWrapper>
                </div>
            </CreatorShell>
        {/if}
    {/if} -->