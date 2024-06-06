<script lang="ts">
	import { page } from '$app/stores';
	import { modal, modalState } from '$stores/layout';
	import { onDestroy, onMount } from 'svelte';
	import { onBeforeClose } from "svelte-modals";
    import { closeModal } from '$utils/modal';
	import { beforeNavigate } from '$app/navigation';
	import { appMobileView } from '$stores/app';
	import { X } from 'phosphor-svelte';
	import { Block, Button, Link, Toolbar } from 'konsta/svelte';
	import { NavigationOption } from '../../app';
	import HorizontalOptionsList from './HorizontalOptionsList.svelte';

    export let title: string | undefined = undefined;

    /**
     * Buttons to render on the shell
     */
    export let actionButtons: NavigationOption[] = [];

    const slideAnimationDuration = 300;

    let url = $page.url.pathname;
    $: if ($page.url.pathname !== url) closeModal();

    let mounted = false;
    let containerEl: HTMLElement;

    onMount(() => {
        mounted = true;
        $modalState = "open";
    });

    beforeNavigate(() => {
        $modalState = "closing";
        $modal = null;
    })

    if (!$appMobileView) {
        onBeforeClose(() => {
            if (mounted === true) {
                $modalState = "closing";
                mounted = false;
                setTimeout(closeModal, slideAnimationDuration);
                return false;
            }
        });
    }

    onDestroy(() => {
        $modalState = "closed";
        window.visualViewport?.removeEventListener("resize", resizeHandler);
    })

    const viewport = window.visualViewport;

    onMount(() => {
        if (viewport) window.visualViewport?.addEventListener("resize", resizeHandler);

        // add an event listener that fires on any input element focus
        document.body.addEventListener("focus", resizeHandler);
        document.body.addEventListener("blur", resizeHandler);
    })

    let height = viewport?.height;

    function resizeHandler() {
        if (!containerEl) return;
        
        if (!/iPhone|iPad|iPod/.test(window.navigator.userAgent)&& viewport?.height && height && viewport.height !== height) {
            containerEl.style.bottom = `${height - viewport.height + 10}px`;
        }
    }
</script>

{#if $appMobileView}
    {#if actionButtons.length > 0}
        <Toolbar top>
            <div class="left">
                <Link onClick={() => closeModal()}>
                    Close
                </Link>
            </div>

            <div class="right">
                {#each actionButtons as item}
                    <Button onClick={item.fn} class="!bg-accent !text-accent-foreground">
                        {item.name}2
                    </Button>
                {/each}
            </div>
        </Toolbar>
        {#if $$slots.titleRight}
            <div class="mx-auto">
                <slot name="titleRight" />
            </div>
        {/if}
    {:else if $$slots.titleRight}
        <Toolbar translucent top class="mx-auto !w-fit mt-4">
            <slot name="titleRight" />
        </Toolbar>
    {/if}
    <Block class="max-h-[80vh] overflow-y-auto {$$props.class??""}">
        <slot />
    </Block>
{:else}
    <div class="fixed top-0 bottom-0 left-0 w-screen h-screen z-[98] flex items-center justify-center pointer-events-none" bind:this={containerEl}>
        <div class="
            max-sm:fixed max-sm:top-0 max-sm:bottom-0 z-[99] max-sm:w-full  max-sm:!pb-0
            {$$props.class??""}
        ">
            {#if mounted}
                <div class="
                    !rounded-3xl
                    max-sm:!rounded-b-none
                    border border-border
                    w-fit mx-auto
                    overflow-clip
                    bg-background
                    p-6
                    {$$props.class}
                " style="pointer-events: auto;"
                >
                    <div class="inner flex flex-col items-center transition-all duration-300
                    {$$props.class}">
                        {#if title}
                            <div class="flex flex-row justify-between w-full border-b border-border pb-2 mb-4">
                                <div class="flex flex-row flex-none gap-4 items-end justify-start">
                                    <button on:click={closeModal}>
                                        <X class="text-foreground w-7 h-7" />
                                    </button>
                                    
                                    <h3 class="title w-full text-left text-foreground font-bold text-xl">{title}</h3>
                                </div>

                                {#if $$slots.titleRight}
                                    <slot name="titleRight" />
                                {/if}
                            </div>
                        {/if}
                    
                        <div class="overflow-y-auto max-h-[65vh] grow shrink w-full scrollbar-hide">
                            <slot />
                        </div>

                        {#if $$slots.footer}
                            <div class="w-full flex flex-row gap-4 items-center justify-end flex-none mt-4">
                                <slot name="footer" />
                            </div>
                        {:else if actionButtons.length > 0}
                            <div class="w-full flex flex-row gap-4 items-center justify-between flex-none mt-4">
                                {#if $$slots.footerExtra}
                                    <slot name="footerExtra" />
                                {:else}
                                    <div class="grow"></div>
                                {/if}
                                
                                <HorizontalOptionsList options={actionButtons} />
                            </div>
                        {/if}
                    </div>
                </div>
            {/if}
        </div>
    </div>
{/if}



<style lang="postcss">
    .title {
        @apply w-full text-left text-foreground font-bold text-lg;
    }
</style>