<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";

    let eventId: string;

    $: eventId = $page.params.id ?? $page.url.searchParams.get("eventId");
</script>

{#key eventId}
    {#if eventId}
        <WithItem tagId={eventId} let:event let:article let:video>
            {#if event}
                <ItemView event={article??video??event} />
            {/if}
        </WithItem>
    {/if}
{/key}