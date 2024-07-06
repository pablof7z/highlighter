<script lang="ts">
	import { layout, pageHeader } from "$stores/layout";
	import { afterUpdate, onDestroy, onMount } from "svelte";
	import HeaderLeftButton from "../HeaderLeftButton.svelte";
	import HeaderRightButton from "../HeaderRightButton.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { browser } from "$app/environment";

    let render = false;
    let navbar: HTMLElement;

    const updateNavbarHeight = () => {
        if (!navbar) {
            document.documentElement.style.setProperty('--navbar-height', `0px`);
            return;
        }
        setTimeout(() => {
            const navbarHeight = navbar.offsetHeight;
            document.documentElement.style.setProperty('--navbar-height', `${navbarHeight}px`);
        }, 10)
    };

    onMount(() => {
        // Initial update
        if (browser) updateNavbarHeight();

        // Update on window resize
        if (browser) window.addEventListener('resize', updateNavbarHeight);
    });

    onDestroy(() => {
        if (browser) window.removeEventListener('resize', updateNavbarHeight);
    });

    afterUpdate(() => {
        setTimeout(updateNavbarHeight);
    });

    $: {
        if (browser) updateNavbarHeight();
        render = render;
    }
</script>

<div class="
    mobile-nav
" bind:this={navbar}>
    <div class="flex flex-row justify-between items-center h-full w-full gap-2">
        {#if $layout.header?.component}
            <div class="w-full h-full flex flex-col">
                <svelte:component
                    this={$layout.header.component}
                    {...$layout.header.props}
                    containerClass={$$props.containerClass}
                    on:resize={updateNavbarHeight}
                />

                {#if $pageHeader?.subNavbarOptions}
                    <div class="py-2 {$$props.containerClass??""}">
                        <HorizontalOptionsList
                            options={$pageHeader.subNavbarOptions}
                            containerClass={$$props.containerClass}
                            bind:value={$pageHeader.subNavbarValue}
                        />
                    </div>
                {/if}
            </div>
        {:else}
            <div class="flex flex-col items-stretch w-full {$$props.containerClass??""}">
                <div class="flex items-center justify-between w-full">
                    <div class="flex flex-row gap-3 items-center w-full">
                        <HeaderLeftButton />

                        {#if $layout?.iconUrl}
                            <img src={$layout.iconUrl} class="w-8 h-8 rounded-full" />
                        {/if}
                        
                        {#if $layout?.title}
                            <div class="
                                flex flex-row
                                text-foreground
                                font-bold text-xl
                                gap-2
                                col-span-5
                                text-center
                                grow truncate
                            ">
                                <span class="truncate">{$layout?.title}</span>
                            </div>
                        {/if}
                    </div>

                    {#if $pageHeader?.right}
                        <HeaderRightButton />
                    {/if}
                </div>

                {#if $pageHeader?.subNavbarOptions}
                    <div class="py-2 {$$props.containerClass??""}">
                        <HorizontalOptionsList
                            options={$pageHeader.subNavbarOptions}
                            bind:value={$pageHeader.subNavbarValue}
                        />
                    </div>
                {/if}
            </div>
        {/if}
    </div>
</div>