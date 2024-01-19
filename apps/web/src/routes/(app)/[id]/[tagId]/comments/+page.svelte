<script lang="ts">
	import { page } from "$app/stores";
	import EventResponses from "$components/EventResponses.svelte";
	import ArticleBannerBackground from "../ArticleBannerBackground.svelte";
	import ItemFooter from "../ItemFooter.svelte";
	import ItemSubpageHeader from "../ItemSubpageHeader.svelte";
	import WithItem from "../WithItem.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;
</script>

{#key tagId}
    <WithItem let:event let:article let:urlPrefix let:eventType>
        {#if event && article && eventType}
            <ArticleBannerBackground {article} />

            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <ItemSubpageHeader {urlPrefix} eventTitle={article.title} title="Comments" />

                <EventResponses {event} class="max-sm:px-4" />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {/if}
    </WithItem>
{/key}