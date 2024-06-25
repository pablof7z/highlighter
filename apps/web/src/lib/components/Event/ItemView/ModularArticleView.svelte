<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import ArticleRenderShell from "../Article/ArticleRenderShell.svelte";
	import HighlightingArea from "$components/HighlightingArea.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import * as Tabs from "$lib/components/ui/tabs";
    import Toc from 'svelte-toc'

    export let event: NDKEvent;

    const eTags = event.getMatchingTags("e");

    let events: Record<NDKEventId, NDKEvent | null> = {};

    for (const eTag of eTags) {
        console.log("fetching", eTag);
        $ndk.fetchEventFromTag(eTag, {subId: 'fetch'}).then(event => {
            const id = eTag[1]!;
            events[id] = event;
            events = events;
        });
    }

    let title: string | undefined = event.tagValue("title");

    try {
        const stupidJsonContent = JSON.parse(event.content);
        title = stupidJsonContent.title;
    } catch {
    }

    let viewMode = "full";
    let expanded: Record<NDKEventId, boolean> = {};
</script>

<ArticleRenderShell {event} isFullVersion={true} isPreview={false} skipImage>
    <div slot="title">
        {title??"Untitled"}
    </div>

    <Tabs.Root bind:value={viewMode} slot="summary">
        <Tabs.List>
            <Tabs.Trigger value="per-chapter">Per Chapter</Tabs.Trigger>
            <Tabs.Trigger value="full">Full View</Tabs.Trigger>
        </Tabs.List>
    </Tabs.Root>

    <div class="flex flex-col w-full" slot="content">
        {#if viewMode === "full"}
            <div class="xl:w-[350px] font-sans fixed -translate-x-full">
                <Toc {title} activeHeadingScrollOffset={-100} />
            </div>
        {/if}
        <div class="flex flex-col">
            {#each eTags as eTag}
                {#if events[eTag[1]]}
                    {#if viewMode === 'full' || expanded[eTag[1]]}
                        <EventWrapper event={events[eTag[1]]} compact>
                            <HighlightingArea tags={events[eTag[1]].referenceTags()}>
                                <EventContent event={events[eTag[1]]} />
                            </HighlightingArea>
                        </EventWrapper>
                    {:else}
                        <h2 class="font-sans text-foreground text-left font-medium text-xl" on:click={() => expanded[eTag[1]] = !expanded[eTag[1]] }>
                            {events[eTag[1]].tagValue("title") ?? "Untitled"}
                        </h2>
                    {/if}
                {:else}
                    <div>Loading {JSON.stringify(eTag)}</div>
                {/if}
            {/each}
        </div>
    </div>
</ArticleRenderShell>

<style lang="postcss">
    h2 {
        scroll-margin-top: 50px;
    }
</style>