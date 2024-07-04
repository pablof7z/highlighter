<script lang="ts">
	import { slide } from 'svelte/transition';
	import { Button } from "$components/ui/button";
	import { CaretUp } from "phosphor-svelte";

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";

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

    const touchmove = (e: TouchEvent) => {
        if (dragging) {
            e.preventDefault();
            dragged = e.touches[0].clientY - position;

            if (collapsed && dragged > 0) dragged = 0;
            else if (!collapsed && dragged < 0) dragged = 0;

            if (collapsed && dragged < -100) {
                collapsed = false;
            } else if (!collapsed && dragged > 100) {
                collapsed = true;
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
        left-0 bottom-0 fixed
        max-sm:right-0 sm:right-[360px]
        sm:left-[var(--navbar-width)]
        sm:w-[360px]
        rounded-t-3xl bg-secondary p-3 px-4 h-auto 
        flex flex-col justify-between items-center
        max-sm:w-full
    ">
    <div class="flex flex-row justify-between {align} w-full gap-2">
        <div class="flex flex-row justify-between {align} w-full gap-2">
            <slot />
        </div>

        <Button
            variant="outline"
            class="
                rounded-full flex-none w-9 h-9 p-0
                transform-gpu transition-transform duration-300
                {!collapsed ? 'rotate-180' : ''}
            "
            on:click={() => (collapsed = !collapsed)}
        >
            <CaretUp class="w-4 h-4" weight="bold" />
        </Button>
    </div>

    {#if !collapsed}
        <div class="flex flex-col gap-2 w-full pt-4" transition:slide>
            <slot name="main" />
        </div>
    {/if}
</div>
