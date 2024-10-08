<script lang="ts">
	import { Readable, derived } from "svelte/store";
	import { NDKArticle, NDKEvent, NDKEventId, NDKHighlight, NDKKind, NDKList, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";
	import Highlight from "$components/Highlight.svelte";
    import { inview } from 'svelte-inview';
	import { pluralize } from "$utils";
	import GroupNote from "$components/Events/GroupNote.svelte";
	import { goto } from "$app/navigation";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import Article from "./Article.svelte";
	import Video from "./Video.svelte";
    import * as Card from "$components/Card";

    export let feed: Readable<NDKEvent[]>;
    export let renderLimit = 10;
    export let urlPrefix: string = "/a/";
    export let showEventsOlderThan: Date | undefined = undefined;
    export let tooNewEvents = new Set<NDKEventId>();
    export let wideView: false | undefined | "first" = undefined;

    /**
     * Whether the feed should be sorted by latest events tagging the event
     * or by publication time
     */
    export let sortByActivity = true;

    const perNoteLatestActivity = new Map<NDKEventId, number>();

    const skipEventIds = new Set<NDKEventId>();
    const allEventIds = new Set<NDKEventId>();

    const renderFeed = derived(feed, $feed => {
        const topLevelNotes = new Map<NDKEventId, NDKEvent>();
        tooNewEvents = new Set<NDKEventId>();

        for (const event of $feed.values()) { allEventIds.add(event.id); }

        // Decide which event ids we are not going to render in the feed
        // Don't render events that are tagging other events we are also going to render
        for (const event of $feed.values()) {
            if (skipEventIds.has(event.id)) { continue; }
            for (const tag of event.getMatchingTags("e")) {
                if (allEventIds.has(tag[1])) {
                    skipEventIds.add(event.id);
                    break;
                }
            }
        }

        const markLatestActivity = (event: NDKEvent, topNoteId: NDKEventId) => {
            const latestActivity = perNoteLatestActivity.get(topNoteId) ?? 0;

            if (event.created_at! > latestActivity)
                perNoteLatestActivity.set(topNoteId, event.created_at!);
        }

        for (const event of $feed.values()) {
            if (skipEventIds.has(event.id)) { continue; }
            if (event.kind === NDKKind.GroupNote || event.kind === NDKKind.Text) {
                topLevelNotes.set(event.id, event);
                markLatestActivity(event, event.id);
            } else if (event.kind === NDKKind.GroupReply) {
                event.getMatchingTags("e").forEach(tag => {
                    const parentId = tag[1];
                    markLatestActivity(event, parentId);
                });
            } else {
                topLevelNotes.set(event.id, event);
                markLatestActivity(event, event.id);
            }
        }

        // filter out events that are newer than the showEventsOlderThan date
        if (showEventsOlderThan) {
            for (const event of topLevelNotes.values()) {
                if (event.created_at!*1000 > showEventsOlderThan.getTime()) {
                    topLevelNotes.delete(event.id);
                    tooNewEvents.add(event.id);
                }
            }
        }

        return Array.from(topLevelNotes.values()).sort((a, b) => {
            if (sortByActivity) {
                const aLatest = perNoteLatestActivity.get(a.id) ?? 0;
                const bLatest = perNoteLatestActivity.get(b.id) ?? 0;

                return bLatest - aLatest;
            } else {
                const aPublication = a.tagValue("published_at") ?? a.created_at!;
                const bPublication = b.tagValue("published_at") ?? b.created_at!;

                return bPublication - aPublication;
            }
        })
    });

    function openNote(e: CustomEvent<{event: NDKEvent, originalEvent: Event }>) {
        const isMobile = window.innerWidth < 640;
        if (isMobile) return;
        const { event, originalEvent } = e.detail;
        originalEvent.preventDefault();
        // navigateToEvent(event);

        goto(`/a/${event.encode()}`);
    }

    export let gridSetup = "grid-cols-1 md:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5";
</script>

<div class="grid {gridSetup} gap-6">
        {#if tooNewEvents.size > 0}
            <div class="w-full flex flex-row items-center justify-center discussion-item transition-all duration-300 sticky top-0 z-50 ">
                <button class="w-fit whitespace-nowrap rounded-full bg-accent p-4"
                    on:click={() => { showEventsOlderThan = new Date(); }}
                >
                    {tooNewEvents.size} new
                    {pluralize(tooNewEvents.size, "post")}
                </button>
            </div>
        {/if}
        {#each $renderFeed.slice(0, renderLimit) as event, i (event.id)}
            {#if event.kind === NDKKind.Text}
                <EventWrapper
                    {event}
                    mostRecentActivity={perNoteLatestActivity.get(event.id)}
                    skipReply={true}
                    showReply={false}
                    {urlPrefix}
                    on:click
                    on:open:note={openNote}
                    on:open:conversation={openNote}
                    {...($$props.eventProps||{})}
                />
            {:else if event.kind === NDKKind.GroupNote}
                <GroupNote {event} {urlPrefix} />
            {:else if event.kind === NDKKind.Article}
                <Article article={NDKArticle.from(event)}
                    wideView={
                        wideView === "first" ? (
                            i === 0 ? true : false
                        ) : wideView
                    }
                />
            {:else if event.kind === NDKKind.HorizontalVideo}
                <Video video={NDKVideo.from(event)}
                    wideView={
                        wideView === "first" ? (
                            i === 0 ? true : false
                        ) : wideView
                    }
                />
            {:else if event.kind === NDKKind.Highlight}
                <Highlight
                    highlight={NDKHighlight.from(event)}
                    {...($$props.eventProps||{})}
                />
            {:else if event.kind === NDKKind.ArticleCurationSet}
                <Card.Curation list={NDKList.from(event)} />
            {:else}
                <EventWrapper
                    {event}
                    mostRecentActivity={perNoteLatestActivity.get(event.id)}
                    skipReply={true}
                    showReply={false}
                    {urlPrefix}
                    {...($$props.eventProps||{})}
                />
            {/if}
        {/each}
</div>

<button class="opacity-0 h-0" on:click={() => { renderLimit++; }} use:inview on:inview_change={(e) => {
    if (e.detail.inView) {
        renderLimit += 10;
    }
}}>
    load more
</button>