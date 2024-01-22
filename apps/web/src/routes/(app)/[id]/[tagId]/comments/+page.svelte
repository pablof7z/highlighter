<script lang="ts">
	import { page } from "$app/stores";
	import EventResponses from "$components/EventResponses.svelte";
	import MobileHeader from "$components/Page/MobileHeader.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { Plus } from "phosphor-svelte";
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

            <MobileHeader
                backButton={urlPrefix}
                backTitle={article.title}
                title="Comments"
            >
                <button slot="button" class="flex-none button button-black">
                    <Plus class="w-5 h-5" />
                </button>
            </MobileHeader>

            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl w-full">
                <ItemSubpageHeader {urlPrefix} eventTitle={article.title} title="Comments" />

                <EventResponses {event} class="max-sm:px-4" />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {/if}
    </WithItem>
{/key}