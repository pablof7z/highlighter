<script lang="ts">
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import { page } from "$app/stores";
	import EventResponses from "$components/EventResponses.svelte";
	import { CaretLeft, ChatCircle } from "phosphor-svelte";
	import ArticleBannerBackground from "../ArticleBannerBackground.svelte";
	import ItemFooter from "../ItemFooter.svelte";
	import WithItem from "../WithItem.svelte";
	import { pageHeader } from "$stores/layout";
	import type { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";

    let tagId: string;
    let urlPrefix: string;
    let article: NDKArticle | undefined;
    let video: NDKVideo | undefined;
    let showComment = false;

    $: tagId = $page.params.tagId;

    $pageHeader = {};

    $: $pageHeader = {
        leftIcon: CaretLeft,
        leftLabel: article?.title ?? "Back",
        leftUrl: urlPrefix,
        title: "Comments",

        rightLabel: "New Comment",
        rightFn: () => {
            showComment = !showComment
        }
    };
</script>

{#key tagId}
    <WithItem let:event bind:article bind:video bind:urlPrefix let:eventType>
        {#if event && (article || video) && eventType}
            <ArticleBannerBackground article={article||video} />
            <MainWrapper>
                <EventResponses {event} class="max-sm:px-4" bind:showComment />
            </MainWrapper>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {/if}
    </WithItem>
{/key}