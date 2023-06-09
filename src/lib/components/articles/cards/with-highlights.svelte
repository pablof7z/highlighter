<script lang="ts">
    import ArticleInterface from "$lib/interfaces/article";
    import type { Observable } from "dexie";
    import HighlightInterface from "$lib/interfaces/highlights";
    import AvatarWithName from "$lib/components/AvatarWithName.svelte";
    import Avatar from "$lib/components/Avatar.svelte";
    import InlineHighlight from "$lib/components/highlights/inline.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
    import ndk from "$lib/stores/ndk";
    import NoteInterface from "$lib/interfaces/notes";
    import { nip19 } from 'nostr-tools';

    /**
     * ID of the article to load
     * @type {string}
     */
    export let id: string;
    let prevId: string;

    /**
     * List of pubkeys to display highlights from
     */
    export let highlightsFrom: string[] | undefined = undefined;

    /**
     * Maximum number of highlights to show by default
     */
    export let maxHighlightCountToShow = 1;

    /**
     * Whether to skip showing the user who did the highlight
     */
    export let skipHighlighter: boolean = false;

    let note: Observable<App.Note[]> | undefined;
    let article: Observable<App.Article[]> | undefined;
    let articleHighlights: Observable<App.Highlight[]> | undefined;
    let articleEvent: NDKEvent;

    let highlightPubkeys: Set<string> = new Set();

    $: if (id !== prevId) {
        prevId = id;

        const isArticle = !!id.match(/:/);

        if (isArticle) {
            article = ArticleInterface.load({id});
        } else {
            note = NoteInterface.load({ids:[id]})
        }

        // load all highlights for this article
        const highlightFilter = {
            articleId: id,
            pubkeys: highlightsFrom,
            limit: 500,
        };

        articleHighlights = HighlightInterface.loadByArticleIdAndPubkeys(
            id,
            highlightsFrom,
            {limit: 500}
        );
    }

    $: if ($article && $article?.length > 0 && !articleEvent) {
        articleEvent = new NDKEvent($ndk, JSON.parse($article[0].event));
    }

    $: if ($articleHighlights && $articleHighlights?.length > 0) {
        for (const highlight of $articleHighlights) {
            highlightPubkeys.add(highlight.pubkey);
        }
    }

    function linkTo(article?: App.Article, note?: App.Note) {
        if (article) {
            return `/a/${articleEvent.encode()}`;
        } else if (note) {
            return `/a/${nip19.noteEncode(note.id)}`;
        }
    }
</script>

<div class="flex flex-col gap-2">
    {#if ($article && $article.length > 0)}
        <div class="flex flex-row items-center gap-4 justify-between">
            <a
                href={linkTo($article[0])}
                class="text-xl font-semibold whitespace-nowrap">
                {$article[0].title}
            </a>
            <div class="flex flex-row items-center gap-2 overflow-auto">
                {#each ($article[0].tags||[]).slice(0, 3) as tag}
                <span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">
                    {tag}
                </span>
                {/each}
            </div>
        </div>

        <AvatarWithName pubkey={$article[0].author} />
    {:else if ($note && $note.length > 0)}
        <a href={linkTo(undefined, $note[0])} class="flex flex-row items-center gap-4 text-orange-500">
            Note
            from <AvatarWithName pubkey={$note[0].pubkey} />
        </a>
    {/if}
</div>

    {#if $articleHighlights && $articleHighlights.length > 0}
        <div class="ml-6">
            <ul role="list" class="flex flex-col gap-4 divide-y divide-gray-200">
                {#each $articleHighlights.slice(0, maxHighlightCountToShow) as highlight}
                    <InlineHighlight {highlight} {skipHighlighter} href={linkTo($article && $article[0], $note && $note[0])} />
                {/each}
            </ul>
        </div>

        <div class="bg-zinc-50 -mx-8 -mb-4 px-8 py-3 flex flex-row items-center justify-between">
            {#if $articleHighlights.length > maxHighlightCountToShow}
                <div class="flex flex-row gap-2 items-center">
                    <div class="isolate flex -space-x-2 overflow-hidden">
                        {#each Array.from(highlightPubkeys).slice(0, 6) as highlightPubkey}
                            <div class="relative z-30 inline-block h-8 w-8 rounded-full ring-2 ring-white">
                                <Avatar pubkey={highlightPubkey} />
                            </div>
                        {/each}
                    </div>

                    <button
                        class="text-xs font-medium text-zinc-600 hover:text-zinc-500"
                        on:click={() => { maxHighlightCountToShow += 5 }}>
                        {$articleHighlights.length-maxHighlightCountToShow} more highlights...
                    </button>
                </div>
            {:else}
                <div></div>
            {/if}

            <a class="
                text-sm
                text-zinc-600 font-semibold
            " href={linkTo(($article && $article[0]), ($note && $note[0]))}>
                Go to article
            </a>
        </div>
    {/if}
