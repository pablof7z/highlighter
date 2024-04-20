<script lang="ts">
	import { Readable, derived } from "svelte/store";
	import { NDKArticle, NDKEvent, NDKEventId, NDKHighlight, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import ForumFeedItem from "./ForumFeedItem.svelte";
	import Note from "./Note.svelte";
	import Highlight from "$components/Highlight.svelte";
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import { navigateToEvent } from "./navigate-to-event";
	import NewPost from "./NewPost/NewPost.svelte";
    import { inview } from 'svelte-inview';

    export let feed: Readable<NDKEvent[]>;
    export let newPostKind: NDKKind | undefined = undefined;
    export let renderLimit = 10;
    export let newPostTags: NDKTag[] = [];
    export let urlPrefix: string = "/e/";

    const perNoteLatestActivity = new Map<NDKEventId, number>();

    const skipEventIds = new Set<NDKEventId>();
    const allEventIds = new Set<NDKEventId>();

    const renderFeed = derived(feed, $feed => {
        const topLevelNotes = new Map<NDKEventId, NDKEvent>();

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

        return Array.from(topLevelNotes.values()).sort((a, b) => {
            const aLatest = perNoteLatestActivity.get(a.id) ?? 0;
            const bLatest = perNoteLatestActivity.get(b.id) ?? 0;

            return bLatest - aLatest;
        })
    });

    function openNote(e: CustomEvent<{event: NDKEvent, originalEvent: Event }>) {
        const isMobile = window.innerWidth < 640;
        if (isMobile) return;
        const { event, originalEvent } = e.detail;
        originalEvent.preventDefault();
        navigateToEvent(event);
    }


</script>

<div class="flex flex-col w-full justify-stretch">
    <div class="discussion-wrapper w-full flex flex-col">
        {#if newPostKind}
            <div class="w-full">
                <NewPost
                    extraTags={newPostTags}
                    kind={newPostKind}
                    placeholder="What's happening?!"
                    autofocus={false}
                />
            </div>
        {/if}
        {#each $renderFeed.slice(0, renderLimit) as event, i (event.id)}
            {#if event.kind === NDKKind.Text}
                <Note
                    {event}
                    mostRecentActivity={perNoteLatestActivity.get(event.id)}
                    skipReply={true}
                    showReply={false}
                    {urlPrefix}
                    on:click
                    on:open:note={openNote}
                    on:open:conversation={openNote}
                />
            {:else if event.kind === NDKKind.Article}
                <ArticleLink
                    article={NDKArticle.from(event)}
                />
            {:else if event.kind === NDKKind.Highlight}
                <Highlight
                    highlight={NDKHighlight.from(event)}
                    position={i}
                    mostRecentActivity={perNoteLatestActivity.get(event.id)}
                    skipReply={true}
                />
            {:else}
                <ForumFeedItem
                    {event}
                    position={i}
                    mostRecentActivity={perNoteLatestActivity.get(event.id)}
                    skipReply={true}
                />
            {/if}
        {/each}
    </div>

    <button class="button" on:click={() => { renderLimit++; }} use:inview on:inview_change={(e) => {
        if (e.detail.inView) {
            renderLimit += 10;
        }
    }}>
        load more
    </button>
</div>


<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
