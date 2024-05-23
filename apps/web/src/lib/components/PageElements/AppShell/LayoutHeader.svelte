<script lang="ts">
	import SearchBar from "$components/Page/SearchBar.svelte";
	import { pageHeader } from "$stores/layout";
	import { afterUpdate, onDestroy, onMount } from "svelte";
	import HeaderLeftButton from "../HeaderLeftButton.svelte";
	import HeaderRightButton from "../HeaderRightButton.svelte";

    let render = false;
    let navbar: HTMLElement;

    $: render =  !!($pageHeader?.component || $pageHeader?.searchBar || $pageHeader?.title || $pageHeader?.left || $pageHeader?.right);

    const updateNavbarHeight = () => {
        if (!navbar) return;
        const navbarHeight = navbar.offsetHeight;
        document.documentElement.style.setProperty('--navbar-height', `${navbarHeight}px`);
        console.log('Navbar height:', navbarHeight);
    };

    onMount(() => {

        // Initial update
        updateNavbarHeight();

        // Update on window resize
        window.addEventListener('resize', updateNavbarHeight);
    });

    onDestroy(() => {
        window.removeEventListener('resize', updateNavbarHeight);
    });

    afterUpdate(() => {
        updateNavbarHeight();
    });
</script>

{#if render}
<div class="
    !fixed top-0
    z-40
    mobile-nav
    w-full
" bind:this={navbar}>
    <div class="flex flex-row justify-between items-center h-full w-full gap-2">
        {#if $pageHeader?.component}
            <div class="w-full h-full">
                <svelte:component
                    this={$pageHeader.component}
                    {...$pageHeader.props}
                    containerClass={$$props.class??""}
                    on:resize={updateNavbarHeight}
                />
            </div>
        {:else if $pageHeader?.searchBar}
            <div class="
                {$$props.class??""}
                w-full mx-auto
            ">
                <SearchBar inputClass="focus:!outline-none focus:!border-none" />
            </div>
        {:else}
            <div class="flex items-center justify-between px-4 w-full">
                {#if $pageHeader?.left}
                    <div class="md:hidden">
                        <HeaderLeftButton />
                    </div>
                {/if}

                <!-- If we have a sidebar, don't show the title on desktop -->
                {#if $pageHeader?.title}
                    <div class="
                        flex flex-row
                        items-center
                        justify-center
                        text-white
                        font-medium
                        gap-2
                        w-full
                        col-span-5
                        text-center
                    ">
                        <span class="truncate">{$pageHeader?.title}</span>
                    </div>
                {/if}

                {#if $pageHeader?.right}
                    <HeaderRightButton />
                {/if}
            </div>
        {/if}
    </div>
</div>
{/if}