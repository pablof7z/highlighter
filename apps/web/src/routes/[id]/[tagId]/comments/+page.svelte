<script lang="ts">
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import { page } from "$app/stores";
	import EventResponses from "$components/EventResponses.svelte";
	import { CaretLeft } from "phosphor-svelte";
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

    const origTitle = $pageHeader?.title;
    $pageHeader = {};


    $: $pageHeader = {
        left: {
            label: article?.title ?? "Back",
            url: urlPrefix,
            icon: CaretLeft
        },
        title: origTitle,
        right: {
            label: "New Comment",
            fn: () => {
                showComment = !showComment
            }
        }
    };
</script>

{#key tagId}
    <WithItem let:event bind:article bind:video bind:urlPrefix let:eventType>
        {#if event && (article || video) && eventType}
            <ItemFooter {event} {urlPrefix} {eventType} />
            <!-- <ArticleBannerBackground article={article||video} /> -->
            
                <EventResponses {event} class="max-sm:px-4" bind:showComment />
        {/if}
    </WithItem>
{/key}