<script lang="ts">
	import { ComponentType, getContext } from "svelte";
	import { WrappedEvent } from "../../../../app";
	import { page } from "$app/stores";
	import * as Content from "$components/Content";

    let wrappedEvent = getContext("wrappedEvent") as WrappedEvent;
    let view: string;

    $: {
        view = $page.params.view;
        // uppercase the first letter of the view
        view = view.charAt(0).toUpperCase() + view.slice(1);
    }

    let component: ComponentType | undefined;
    $: component = (Content.Views[view] as ComponentType);
</script>

{#if component}
    <svelte:component this={component} {wrappedEvent} />
{:else}
    <p>404 {view}</p>
{/if}