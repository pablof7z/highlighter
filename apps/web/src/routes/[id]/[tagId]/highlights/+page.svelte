<script lang="ts">
	import { page } from "$app/stores";
	import { CaretLeft } from "phosphor-svelte";
	import ItemFooter from "../ItemFooter.svelte";
	import WithItem from "../WithItem.svelte";
	import ArticleBannerBackground from "../ArticleBannerBackground.svelte";
	import Highlights from "$components/Highlights.svelte";
	import { pageHeader } from "$stores/layout";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";

    let tagId: string;
    let urlPrefix: string;
    let article: NDKArticle | undefined;
    let video: NDKVideo | undefined;

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
    };
</script>

{#key tagId}
    <WithItem let:event bind:article bind:video bind:urlPrefix let:eventType>
        {#if event && article && eventType}
        <!-- <ArticleBannerBackground {article} /> -->
        <ItemFooter {event} {urlPrefix} {eventType} />

            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <Highlights filter={article.filter()} />
            </div>

        {/if}
    </WithItem>
{/key}