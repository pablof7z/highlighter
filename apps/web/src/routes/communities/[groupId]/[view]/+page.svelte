<script lang="ts">
	import { ComponentType, getContext } from "svelte";
	import { page } from "$app/stores";
	import * as Groups from "$components/Groups";
	import { Readable } from "svelte/store";
	import { Navigation } from "$utils/navigation";

    let group = getContext("group") as Readable<Groups.Group>;
    let view: string;

    const optionManager = getContext("optionManager") as Navigation;

    $: {
        view = $page.params.view;
        // uppercase the first letter of the view
        view = view.charAt(0).toUpperCase() + view.slice(1);
    }

    let component: ComponentType | undefined;
    $: component = (Groups.Views[view] as ComponentType);
</script>

{#if component}
    <svelte:component
        this={component}
        {group}
        {optionManager}
    />
{:else}
    <p>404 {view}</p>
{/if}