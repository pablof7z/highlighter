<script lang="ts">
	import { page } from "$app/stores";
	import Curations from "$components/Curations.svelte";
	import ItemFooter from "../ItemFooter.svelte";
	import WithItem from "../WithItem.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;
</script>

{#key tagId}
    <WithItem let:event let:article let:video let:urlPrefix let:eventType let:authorUrl>
        {#if event && eventType}
            <ItemFooter {event} {eventType} />
            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <Curations filter={event.filter()} />
            </div>

        {/if}
    </WithItem>
{/key}