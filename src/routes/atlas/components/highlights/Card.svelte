<script lang="ts">

    import NoteInterface from '$lib/interfaces/notes';
    import ArticleInterface from '$lib/interfaces/article';
    import ZapInterface from '$lib/interfaces/zap';

    import CopyIcon from '$lib/icons/Copy.svelte';
    import CheckIcon from '$lib/icons/Check.svelte';
    import BoostIcon from '$lib/icons/Boost.svelte';
    import ViewIcon from '$lib/icons/View.svelte';
    import ZapIcon from '$lib/icons/Zap.svelte';
    import CommentIcon from '$lib/icons/Comment.svelte';
    import LinkIcon from '$lib/icons/Link.svelte';

    import Bookmark from '$lib/components/events/buttons/bookmark.svelte';

    import { openModal } from 'svelte-modals'
    import { Tooltip } from 'flowbite-svelte';

    import Avatar from '$lib/components/Avatar.svelte';
    import Name from '$lib/components/Name.svelte';
    import ndk from '$lib/stores/ndk';
    import { NDKEvent } from '@nostr-dev-kit/ndk';
    import {nip19} from 'nostr-tools';
    import Comment from '$lib/components/Comment.svelte';
    import Note from '$lib/components/notes/card.svelte';

    import ZapModal from '$lib/modals/Zap.svelte';
    import BookmarkModal from '$lib/modals/Bookmark.svelte';

    import type { NostrEvent } from '@nostr-dev-kit/ndk/lib/src/events';

    export let highlight: App.Highlight;
    export let skipUrl: boolean = false;
    export let skipTitle: boolean = false;
    export let disableClick: boolean = false;
    let prevHighlightId: string | undefined = undefined;

    let replies;
    let articles, article: App.Article | undefined;
    let zaps;
    let zappedAmount: number;
    let domain: string;
    let pubkey: string;
    let showComments = false;
    let showReplies = false;
    let event: NDKEvent;
    let articleLink: string;
    let naddr: string;
    let copiedEventId = false;
    let highlightNoteId = '';

    function copyId() {
        if (!highlightNoteId) return;
        navigator.clipboard.writeText(highlightNoteId);
        copiedEventId = true;
        setTimeout(() => {
            copiedEventId = false;
        }, 1500);
    }

    async function boost() {
        let highlightEvent = new NDKEvent($ndk, JSON.parse(highlight.event));
        let articleEvent;

        const tags = [];
        tags.push(highlightEvent.tagReference());

        const pTag = highlightEvent.getMatchingTags('p')[0];
        if (pTag && pTag[1]) {
            tags.push(['p', pTag[1], "highlighter"]);
        }

        if (article) {
            try {
                articleEvent = new NDKEvent($ndk, JSON.parse(article.event));
                tags.push(articleEvent.tagReference());

                // should this be checking for the pubkey of the article event as the publisher?
                // then for `p` tags marked as a `author` for the author instead?
                // then we would need to change how nip-23s are generated to include the `p` author tag
                // why didn't I use the `p` tag at first for this?
                const pTag = articleEvent.getMatchingTags('p')[0];
                if (pTag && pTag[1]) {
                    tags.push(['p', pTag[1], "author"]);
                } else {

                }
            } catch (e) {
                console.error(e);
            }
        } else {
            // check if this highlightEvent has an `r` tag
            const rTag = highlightEvent.getMatchingTags('r')[0];

            if (rTag && rTag[1]) {
                tags.push(['r', rTag[1]]);
            } else {
                console.error('no article found for this highlight');
            }
        }

        const boostEvent = new NDKEvent($ndk, {
            content: JSON.stringify(highlightEvent.rawEvent()),
            created_at: Math.floor(Date.now() / 1000),
            kind: 6,
            tags,
        } as NostrEvent);

        await boostEvent.sign();
        console.log('boostEvent', await boostEvent.toNostrEvent());
        await boostEvent.publish();

        alert('event boosted; displaying boosts is WIP -- BRB! 😉')
    }

    function onContentClick(e) {
        if (disableClick) return;

        // see if there is an element that has attribute data-highlight with the id of the highlight
        // if there is, then we want to scroll to that element
        const el = document.querySelector(`[data-highlight-id="${highlight.id}"]`);
        if (el) {
            el.scrollIntoView({ behavior: 'smooth' });
            el.classList.add('bg-slate-100');
            setTimeout(() => {
                el.classList.remove('bg-slate-100');
            }, 1000);

            e.preventDefault();
        } else {
            if (window && window.find && window.find(highlight.content)) {
                e.preventDefault();
            }
        }
    }

    $: {
        if (prevHighlightId !== highlight.id && highlight.id) {
            article = undefined;
            showComments = false;
            showReplies = false;
            prevHighlightId = highlight.id;

            highlightNoteId = nip19.noteEncode(highlight.id);

            if (highlight.articleId) {
                const [kind, pubkey, identifier] = highlight.articleId.split(':');
                naddr = nip19.naddrEncode({
                    kind: parseInt(kind),
                    pubkey,
                    identifier
                })
                articleLink = `/a/${naddr}`;
            } else {
                // see if this highlight.event has a p tag
                try {
                    const event = new NDKEvent(undefined, JSON.parse(highlight.event));
                    const pTag = event.getMatchingTags('p')[0];

                    articleLink = `/load?url=${encodeURIComponent(highlight.url)}`

                    if (pTag && pTag[1]) {
                        articleLink += `&author=${encodeURIComponent(pTag[1])}`;
                    }
                } catch (e) {
                }
            }

            replies = NoteInterface.load({ replies: [highlight.id] });
            zaps = ZapInterface.load({eventId: highlight.id});

            if (highlight.articleId) {
                console.log('calling into loading article', highlight.articleId)
                articles = ArticleInterface.load({ id: highlight.articleId });
            }
        }

        if ($articles) article = $articles[0];

        if (!event || event.id !== highlight.id) {
            event = new NDKEvent($ndk, JSON.parse(highlight.event));
        }

        // count zap amount
        if ($zaps) {
            zappedAmount = $zaps.reduce((acc, zap) => {
                return acc + zap.amount;
            }, 0);
        }

        pubkey = highlight.pubkey;

        if (highlight.url)
            domain = new URL(highlight.url).hostname;
    }

    function dragStart(event: DragEvent) {
        if (!event.dataTransfer) return;

        const e = new NDKEvent($ndk, JSON.parse(highlight.event));
        const tag = e.tagReference();

        event.dataTransfer.setData('id', highlight.id as string);
        event.dataTransfer.setData('tag', JSON.stringify(tag));
    }
</script>

<div
    class="flex flex-col h-full"
    draggable={true}
    on:dragstart={dragStart}
>
    <div class="
        shadow
        flex flex-col h-full gap-4
        border border-zinc-200 hover:border-zinc-200
        px-6 pt-6 pb-4 rounded-xl
        bg-white hover:bg-slate-50 transition duration-200 ease-in-out
    " style="max-height: 40rem;">

        {#if !skipTitle}
            <!-- Title -->
            <div class="flex flex-row justify-between items-start">
                <div class="flex flex-col">
                    <a href={articleLink} class="
                        text-lg font-semibold text-zinc-900 hover:text-zinc-600
                    ">
                        {article?.title||domain||'Untitled'}
                    </a>
                    {#if article?.author}
                        <div class="flex flex-row gap-4 items-start text-sm text-zinc-400">
                            <Name pubkey={article.author} klass="h-8" />
                        </div>
                    {:else if article?.url}
                        <div class="text-slate-600 text-xs">
                            {article.url}
                        </div>
                    {/if}
                </div>

                <button class="text-gray-200 hover:text-gray-400 transition duration-300 w-fit"
                    on:click={() => {
                        navigator.clipboard.writeText(highlight.event);
                    }}
                >
                    <ViewIcon />
                </button>
                <Tooltip  color="black">Copy event JSON</Tooltip>
            </div>
        {/if}

        <!-- Content -->
        <a href={articleLink} on:click={onContentClick} class="
            leading-relaxed
            h-full flex flex-col sm:text-justify
            text-black
            px-6 py-4
            my-2
            overflow-auto
        ">
            {highlight.content}
        </a>

        <!-- Footer -->
        <div class="
            flex flex-row
            items-center
            justify-between
            w-full
            rounded-b-lg
            py-4
            pb-0
        ">
            <div class="flex flex-row gap-4 items-center whitespace-nowrap">
                <div class="flex flex-row gap-4 items-center justify-center">
                    <Avatar pubkey={highlight.pubkey} klass="h-6" />
                </div>
                {#if ($replies||[]).length > 0}
                    <button class="text-sm text-gray-500"
                        on:click={() => { showReplies = !showReplies }}
                    >
                        <span class=" px-4 py-2 rounded-xl flex flex-col items-center justify-center text-xs">
                            {($replies||[]).length} comments
                        </span>
                    </button>
                    <Tooltip  color="black">
                        View comments
                    </Tooltip>
                {/if}
            </div>

            <div class="flex flex-row gap-4 items-center">
                <Bookmark {event}  />

                <button class="
                    text-slate-500 hover:text-orange-500
                    flex flex-row items-center gap-2
                " on:click={() => { openModal(ZapModal, { highlight, article }) }}>
                    <ZapIcon />
                    {zappedAmount}
                </button>
                <Tooltip  color="black">Zap</Tooltip>

                <button class="
                    text-slate-500 hover:text-orange-500
                    flex flex-row items-center gap-2
                " on:click={boost}>
                    <BoostIcon />
                </button>
                <Tooltip  color="black">Boost</Tooltip>

                <button class="
                    text-slate-500 hover:text-orange-500
                    flex flex-row items-center gap-2
                " on:click={() => { showComments = !showComments; showReplies = showComments; }}>
                    <CommentIcon />
                    {($replies||[]).length}
                </button>
                <Tooltip  color="black">Discuss</Tooltip>

                {#if highlight.articleId}
                    <button class="
                        flex flex-row gap-2 items-center text-slate-500 hover:text-orange-500
                    " on:click={copyId}>
                        {#if copiedEventId}
                            <CheckIcon />
                        {:else}
                            <CopyIcon />
                        {/if}
                    </button>
                    <Tooltip  color="black">
                        Copy highlight Nostr ID
                    </Tooltip>
                {:else if highlight.url && !skipUrl}
                    <a href={highlight.url} class="text-gray-500 hover:text-orange-500 flex flex-row gap-3 text-sm items-center">
                        {domain}
                    </a>
                    <Tooltip  color="black">
                        {highlight.url}
                    </Tooltip>
                {/if}

                <a href={`/e/${highlightNoteId}`} class="
                    text-slate-500 hover:text-orange-500
                    flex flex-row items-center gap-2
                ">
                    <LinkIcon />
                </a>
                <Tooltip  color="black">Link to this highlight</Tooltip>
            </div>
        </div>

        <div class={(showComments ? `block` : 'hidden') + " w-full text-gray-200 text-lg"}>
            <Comment op={event} on:commented={() => { showComments = false }} />
        </div>
    </div>

    <div class="ml-6 {showReplies ? 'block' : 'hidden'}">
        {#each ($replies||[]) as reply}
            <Note note={reply} />
        {/each}
    </div>
</div>