<script lang="ts">
	import { page } from "$app/stores";
    import * as Content from "$components/Content";
	import { ComponentType } from "svelte";

    let eventId: string;
    let view: string;

    $: eventId = $page.params.id ?? $page.url.searchParams.get("eventId");
    $: {
        view = $page.params.view ?? $page.url.searchParams.get('view') ?? 'event';
        view = view.charAt(0).toUpperCase() + view.slice(1);
    }

    let component: ComponentType;
    $: component = (Content.Views[view] as ComponentType) ?? Content.Views.Body;
</script>

{#key eventId}
    {#if eventId}
        <Content.Root bech32={eventId} let:wrappedEvent>
            <Content.Shell {wrappedEvent}>
                <svelte:component this={component} {wrappedEvent} />
            </Content.Shell>
        </Content.Root>
    {/if}
{/key}