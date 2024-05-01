<script lang="ts">
    import ArticleView from "$components/ArticleView.svelte";
	import { page } from "$app/stores";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { goto } from "$app/navigation";
	import WithItem from "../../[id]/[tagId]/WithItem.svelte";
	import CreatorShell from "$components/Creator/CreatorShell.svelte";
	import MoreFromUser from "$components/Creator/MoreFromUser.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import ListView from "$components/ListView.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import ItemFooter from "../../[id]/[tagId]/ItemFooter.svelte";
	import VideoView from "../../[id]/[tagId]/VideoView.svelte";
	import ForumFeedItem from "$components/Feed/ForumFeedItem.svelte";
	import { detailView, pageMainContentMaxWidth } from "$stores/layout";

    $detailView = null;

    let id: string;

    $: id = $page.params.id;

    let mxClass = "";

    let event: NDKEvent | null;
    let eventType: string; 

    $: if (event) {
        const author = event.author;

        if (event.kind === event.dTag) {
            goto(`/${author.npub}/${event.dTag}`);
        }
    }

    $: switch (eventType) {
        case 'short-note': $pageMainContentMaxWidth = 'max-w-3xl'; break;
        case 'highlight': $pageMainContentMaxWidth = 'max-w-3xl'; break;
    }
</script>

{#key id}
        <WithItem tagId={id} bind:event let:article let:video let:urlPrefix bind:eventType let:isFullVersion let:authorUrl>
            {#if event && eventType}
                {#if eventType === "article" && article}
                    <MainWrapper
                        class="flex-col justify-start items-start gap-2 sm:gap-8 flex pb-6 sm:py-6"
                        marginClass={`max-w-3xl`}
                        mobilePadded={false}
                    >
                        <ArticleView
                            {article}
                            {isFullVersion}
                        />

                        <MoreFromUser user={event.author} />
                    </MainWrapper>

                    <ItemFooter {event} {urlPrefix} {eventType} {mxClass} />
                {:else if eventType === "video" && video}
                    <div class="flex-col justify-start items-start gap-8 flex {mxClass} max-w-3xl py-6">
                        <VideoView
                            {video}
                            {isFullVersion}
                        />
                    </div>

                    <ItemFooter {event} {urlPrefix} {eventType} {mxClass} />
                {:else if ["group-note"].includes(eventType)}
                    <div class="mx-auto max-w-3xl">
                        <div class="flex flex-col w-full justify-stretch">

                            <div class="discussion-wrapper w-full flex flex-col">
                                <ForumFeedItem {event} {urlPrefix} {eventType} />
                            </div>
                        </div>
                    </div>
                {:else if ["short-note"].includes(eventType)}
                        <div class="flex flex-col w-full justify-stretch">

                            <div class="discussion-wrapper w-full flex flex-col">
                                <EventWrapper {event} expandReplies={true} threadView={true} />
                            </div>
                        </div>
                {:else if eventType === 'curation'}
                    <ListView {event} {urlPrefix} {authorUrl} />
                {:else if eventType === 'highlight'}
                    <Highlight
                        highlight={NDKHighlight.from(event)}
                        {urlPrefix}
                        {authorUrl}
                        compact={true}
                        expandReplies={true}
                    />
                {:else}
                    <CreatorShell user={event.author}>
                        <div class="max-w-3xl">
                            <EventWrapper {event} class="bg-base-200 p-6 rounded-box">
                                <EventContent ndk={$ndk} {event} class="prose highlight" />
                            </EventWrapper>
                        </div>
                    </CreatorShell>
                {/if}
            {/if}

        </WithItem>
{/key}
<!--
<LoadingScreen ready={!!event}>
    <MainWrapper>

        <h1 class="text-2xl font-bold mb-4">Article</h1>
        {#if event}
            <ArticleView article={NDKArticle.from(event)} isFullVersion={true} />
        {/if}
    </MainWrapper>
</LoadingScreen> -->