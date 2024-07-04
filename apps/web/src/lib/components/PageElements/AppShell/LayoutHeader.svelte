<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { afterUpdate, onDestroy, onMount } from "svelte";
	import HeaderLeftButton from "../HeaderLeftButton.svelte";
	import HeaderRightButton from "../HeaderRightButton.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { browser } from "$app/environment";

    let render = false;
    let navbar: HTMLElement;

    $: render =  !!($pageHeader?.component || $pageHeader?.searchBar || $pageHeader?.title || $pageHeader?.left || $pageHeader?.right);

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

{#if render}
<div class="
    !fixed top-0
    left-[var(--navbar-width)]
    z-40
    mobile-nav
    w-full
" bind:this={navbar}>
    <div class="flex flex-row justify-between items-center h-full w-full gap-2">
        {#if $pageHeader?.component}
            <div class="w-full h-full flex flex-col">
                <svelte:component
                    this={$pageHeader.component}
                    {...$pageHeader.props}
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
                <div class="flex items-center justify-between px-4">
                    {#if $pageHeader?.left}
                        <HeaderLeftButton />
                    {/if}

                    {#if $pageHeader?.title}
                        <div class="
                            flex flex-row
                            items-center
                            justify-center
                            text-foreground
                            font-medium
                            gap-2
                            col-span-5
                            text-center
                            p-3
                            grow truncate
                            w-8/12
                        ">
                            <span class="truncate">{$pageHeader?.title}</span>
                        </div>
                    {/if}

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
{/if}