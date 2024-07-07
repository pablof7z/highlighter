<script lang="ts">
	import { page } from "$app/stores";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
    import * as Content from "$components/Content";

    let eventId: string;
    let mode: string;

    $: eventId = $page.params.id ?? $page.url.searchParams.get("eventId");
    $: mode = $page.params.mode ?? $page.url.searchParams.get('view') ?? 'event';
</script>

{#key eventId}
    {#if eventId}
        <WithItem tagId={eventId} let:event>
            {#if event}
                <Content.Shell {event}>
                    {#if mode === 'event'}
                        <Content.Body />
                    {:else if mode === "comments"}
                        <Content.Comments />
                    {/if}
                </Content.Shell>
            {/if}
        </WithItem>
    {/if}
{/key}