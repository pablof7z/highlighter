<script lang="ts">
    import ArticleView from "$components/ArticleView.svelte";
	import { page } from "$app/stores";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { goto } from "$app/navigation";
	import WithItem from "../../[id]/[tagId]/WithItem.svelte";
	import CreatorShell from "$components/Creator/CreatorShell.svelte";
	import MoreFromUser from "$components/Creator/MoreFromUser.svelte";
	import EventResponses from "$components/EventResponses.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import FeedGroupPost from "$components/Feed/FeedGroupPost.svelte";
	import ListView from "$components/ListView.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import ItemFooter from "../../[id]/[tagId]/ItemFooter.svelte";
	import VideoView from "../../[id]/[tagId]/VideoView.svelte";

    let id: string;

    $: id = $page.params.id;

    let mxClass = "";

    let event: NDKEvent | null;

    $: if (event && event.kind === NDKKind.Article) {
        const author = event.author;
        goto(`/${author.npub}/${event.dTag}`);
    }
</script>

{#key id}
    <WithItem tagId={id} bind:event let:article let:video let:urlPrefix let:eventType let:isFullVersion let:authorUrl>
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
            {:else if ["group-note", "short-note"].includes(eventType)}
                <div class="flex-col justify-start items-start gap-8 flex {mxClass} max-w-3xl">
                    <div class="w-full flex items-center flex-col justify-center">
                        <div class="w-full">
                            <FeedGroupPost {event} class="bg-base-200 rounded-box p-6" />
                        </div>
                    </div>

                    <div class="divider my-0"></div>

                    <EventResponses {event} />

                </div>
            {:else if eventType === 'curation'}
                <ListView {event} {urlPrefix} {authorUrl} />
            {:else if eventType === 'highlight'}
                <CreatorShell user={event.author}>
                    <div class="max-w-2xl mx-auto w-full">
                        <Highlight highlight={NDKHighlight.from(event)} {urlPrefix} {authorUrl} />
                    </div>
                </CreatorShell>
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