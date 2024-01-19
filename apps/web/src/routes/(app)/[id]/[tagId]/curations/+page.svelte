<script lang="ts">
	import { page } from "$app/stores";
	import Curations from "$components/Curations.svelte";
	import ArticleBannerBackground from "../ArticleBannerBackground.svelte";
	import ItemFooter from "../ItemFooter.svelte";
	import ItemSubpageHeader from "../ItemSubpageHeader.svelte";
	import WithItem from "../WithItem.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;
</script>

{#key tagId}
    <WithItem let:event let:article let:video let:urlPrefix let:eventType let:authorUrl>
        {#if event && eventType}
            {#if article}
                <ArticleBannerBackground {article} />
            {/if}

            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <ItemSubpageHeader {urlPrefix} eventTitle={article?.title || video.title}  title="Curations" />

                <Curations filter={event.filter()} />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {/if}
    </WithItem>
{/key}