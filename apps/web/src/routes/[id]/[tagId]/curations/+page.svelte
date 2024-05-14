<script lang="ts">
	import { page } from "$app/stores";
	import Curations from "$components/Curations.svelte";
	import ItemFooter from "$components/Event/ItemView/ItemFooter.svelte";
	import WithItem from "$components/Event/ItemView/WithItem.svelte"

    let id: string;
    let tagId: string;
    let urlPrefix: string;

    $: {
        id = $page.params.id;
        tagId = encodeURIComponent($page.params.tagId);
        urlPrefix = `/${id}/${tagId}`;
    }
</script>

{#key tagId}
    <WithItem let:event let:article let:video let:urlPrefix let:eventType let:authorUrl>
        {#if event && eventType}
            <ItemFooter {event} {eventType} {urlPrefix} />
            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <Curations filter={event.filter()} />
            </div>

        {/if}
    </WithItem>
{/key}