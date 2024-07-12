<script lang="ts">
	import { slide } from 'svelte/transition';
	import { Button } from "$components/ui/button";
	import { CaretUp } from "phosphor-svelte";
	import { createEventDispatcher, onMount } from 'svelte';

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";
    export let mainView: string | undefined = undefined;
    export let collapse = () => {
        collapsed = true;
        mainView = undefined;
        dispatch("collapse");
    }

    /**
     * Whether, when the component is mounted, it should be opened
     */
    export let openOnMount: boolean | undefined = undefined;

    const dispatch = createEventDispatcher();

    /**
     * Whether to hide the collapsed view when expanded
     */
    export let hideCollapsedView = false;

    let position = 0;
    let dragged = 0;

    function touchstart(e: TouchEvent) {
        dragging = true;
        position = e.touches[0].clientY;
    }

    function touchend() {
        dragging = false;
        position = 0;
    }

    onMount(() => {
        if (openOnMount) {
            collapsed = false;
        }
    })

    const touchmove = (e: TouchEvent) => {
        if (dragging) {
            e.preventDefault();
            dragged = e.touches[0].clientY - position;

            if (collapsed && dragged > 0) dragged = 0;
            else if (!collapsed && dragged < 0) dragged = 0;

            if (collapsed && dragged < -100) {
                collapsed = false;
            } else if (!collapsed && dragged > 100) {
                collapse()
            }
        }
    }

    function open(view?: any | string) {
        collapsed = false;
        if (typeof view !== "string")
            view = "main"

        mainView = view;
    }

	function toggleCollapse() {
        if (collapsed) {
            open();
        } else {
            collapse();
        }
	}
</script>

<div
    on:touchstart={touchstart}
    on:touchend={touchend}
    on:touchmove={touchmove}
    style="background: rgba(51, 51, 51, 0.60); {
        (dragging) ? "transform: translateY(" + dragged/50 + "px);" : ""
    }"
    class="
        backdrop-blur-lg
        overflow-clip
        max-sm:p-4 max-sm:px-6
        max-sm:right-0 sm:right-[360px]
        rounded-t-3xl p-3 px-4 h-auto 
        flex flex-col justify-between items-center
    ">
    {#if !hideCollapsedView || collapsed}
        <div class="flex flex-row justify-between {align} w-full gap-2" transition:slide={{axis: 'y'}}>
            <div class="flex flex-row justify-between {align} w-full gap-2">
                <slot {collapsed} {open} {collapse} />
            </div>

            <Button
                variant="outline"
                class="
                    rounded-full flex-none w-12 h-12 p-2
                    transform-gpu transition-transform duration-300
                    {!collapsed ? 'rotate-180' : ''}
                "
                on:click={toggleCollapse}
            >
                <CaretUp class="w-full h-full" weight="bold" />
            </Button>
        </div>
    {/if}

    {#if !collapsed}
        <div class="flex flex-col gap-2 w-full pt-4 max-h-[50vh] overflow-y-auto scrollbar-hide" transition:slide>
            <slot name="main" />
        </div>
    {/if}
</div>
