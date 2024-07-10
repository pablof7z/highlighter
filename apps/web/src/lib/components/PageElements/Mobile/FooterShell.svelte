<script lang="ts">
	import { slide } from 'svelte/transition';
	import { Button } from "$components/ui/button";
	import { CaretUp } from "phosphor-svelte";

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";
    export let mainView: string | undefined = undefined;

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

    function collapse() {
        collapsed = true;
        mainView = undefined;
    }

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
</script>

<div
    on:touchstart={touchstart}
    on:touchend={touchend}
    on:touchmove={touchmove}
    style={
        (dragging) ? "transform: translateY(" + dragged/50 + "px);" : ""
    }
    class="
        max-sm:p-4 max-sm:px-6
        max-sm:right-0 sm:right-[360px]
        max-sm:rounded-t-3xl bg-secondary p-3 px-4 h-auto 
        flex flex-col justify-between items-center
    ">
    <div class="flex flex-row justify-between {align} w-full">
        <div class="flex flex-row justify-between {align} w-full gap-2">
            <slot />
        </div>

        <Button
            variant="outline"
            class="
                rounded-full flex-none w-12 h-12 p-2
                transform-gpu transition-transform duration-300
                {!collapsed ? 'rotate-180' : ''}
            "
            on:click={collapse}
        >
            <CaretUp class="w-full h-full" weight="bold" />
        </Button>
    </div>

    {#if !collapsed}
        <div class="flex flex-col gap-2 w-full pt-4 max-h-[50vh] overflow-y-auto scrollbar-hide" transition:slide>
            <slot name="main" />
        </div>
    {/if}
</div>
