<script lang="ts">
	import { Button } from "$components/ui/button";
	import { CaretUp, X } from "phosphor-svelte";
	import { createEventDispatcher, onMount, SvelteComponent } from 'svelte';
	import { Writable } from "svelte/store";
	import { layout } from "$stores/layout";

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";
    export let maxHeight = "50vh";
    export let visibleHeight = 60;
    export let padding = "calc(var(--safe-area-inset-bottom) + 0.5rem)";
    export let placeholder: string | undefined = "Reply";

    export let content = "";

    let el: HTMLDivElement;

    // record height of el height as footer-height
    $: if (el && (collapsed || !collapsed)) {
        setTimeout(() => {
            document?.documentElement.style.setProperty('--footer-height', el.clientHeight + 'px');
        }, 50)
    }
</script>

<div
    bind:this={el}
    class="
        footer-shell
        max-sm:backdrop-blur-lg
        overflow-clip
        max-sm:p-2 max-sm:px-3
        max-sm:right-0 sm:right-[360px]
        py-3
        flex flex-row justify-between items-center
        !pb-[calc(var(--bottom-padding)+0.5rem)]

        { !$layout.sidebar && !$layout.fullWidth ? "max-w-[var(--content-focused-width)] mx-auto w-full" : "" }
        
        {$$props.class??""}
    ">
    <slot />
</div>
