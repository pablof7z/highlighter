<script lang="ts">
	import { slide } from "svelte/transition";

    export let title: string | undefined = undefined;
    export let collapsed: boolean | undefined = undefined;

    function titleClicked() {
        if (collapsed === undefined) return;

        collapsed = !collapsed;
    }
</script>

<div class="
    w-full
    p-4 bg-foreground/10 rounded flex-col justify-start items-start gap-3 flex
    {$$props.class??""}
">
    {#if title}
        <button
            class="text-left self-stretch pl-2 justify-between items-center inline-flex"
            on:click={titleClicked}
        >
            <div class="grow shrink basis-0 text-neutral-200 text-2xl font-semibold font-['Inter'] leading-[30.72px]">
                {title}
            </div>
        </button>
    {/if}

    {#if !collapsed}
        <div class="
            self-stretch justify-start items-start gap-3 inline-flex
            flex-col {$$props.innerClass??""}
        " transition:slide>
            <slot />
        </div>
    {/if}
</div>