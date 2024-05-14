<script lang="ts">
	import { page } from "$app/stores";
	import { CaretLeft } from "phosphor-svelte";
	import { pageHeader } from "$stores/layout";
	import { NDKKind, type NDKArticle, type NDKVideo } from "@nostr-dev-kit/ndk";
	import FilterFeed from '$components/Feed/FilterFeed.svelte';
    import WithItem from '$components/Event/ItemView/WithItem.svelte';
    import ItemFooter from '$components/Event/ItemView/ItemFooter.svelte';

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

            <FilterFeed filters={[
                { kinds: [NDKKind.Text, NDKKind.GroupReply ], ...event.filter() }
            ]} />
        {/if}
    </WithItem>
{/key}