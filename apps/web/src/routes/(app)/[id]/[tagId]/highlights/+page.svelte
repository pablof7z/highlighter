<script lang="ts">
	import { page } from "$app/stores";
	import { ArrowLeft } from "phosphor-svelte";
	import ItemFooter from "../ItemFooter.svelte";
	import WithItem from "../WithItem.svelte";
	import ArticleBannerBackground from "../ArticleBannerBackground.svelte";
	import ItemSubpageHeader from "../ItemSubpageHeader.svelte";
	import Highlights from "$components/Highlights.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;
</script>

{#key tagId}
    <WithItem let:event let:article let:urlPrefix let:eventType>
        {#if event && article && eventType}
            <ArticleBannerBackground {article} />

            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <ItemSubpageHeader {urlPrefix} eventTitle={article.title} title="Highlights" />

                <Highlights filter={article.filter()} />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {/if}
    </WithItem>
{/key}