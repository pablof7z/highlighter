<script lang="ts">
	import Device from 'svelte-device-info';
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { pageHeaderComponent, pageNavigationOptions, pageNavigationOptionsValue } from "$stores/layout";
	import { onDestroy } from "svelte";

    let container: HTMLElement;

    function handleScroll() {
        if (!container) {
            console.error("container went await")
            document.removeEventListener("scroll", handleScroll);
            return;
        }
        
        if ($pageHeaderComponent) return;
        
        let leftMargin = window.scrollY * 0.9;

        if (leftMargin > 48) leftMargin = 48;
        if (leftMargin < 0) leftMargin = 0;

        container.style.marginLeft = `${leftMargin}px`;
    }

    if (Device.isMobile) document.addEventListener("scroll", handleScroll);

    onDestroy(() => {
        document.removeEventListener("scroll", handleScroll);
    });

    let render = false;

    $: render = !!($pageNavigationOptions.length > 0 || $pageHeaderComponent);
</script>

{#if render}
    <div class="
        sticky
        top-[var(--layout-header-height)]
        {
            $pageHeaderComponent?.component ?
            $pageHeaderComponent?.containerClass : ""
        }
        z-50
    " bind:this={container}>
        {#if $pageHeaderComponent?.component}
            <svelte:component this={$pageHeaderComponent.component} {...$pageHeaderComponent.props} />
        {/if}
        
        {#if $pageNavigationOptions && $pageNavigationOptions.length > 0}
            <div class="h-[var(--layout-header-height)]">
                <HorizontalOptionsList
                    options={$pageNavigationOptions}
                    bind:value={$pageNavigationOptionsValue}
                    class="w-full gap-0"
                />
            </div>
        {/if}
    </div>  
{/if}