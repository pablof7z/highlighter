<script lang="ts">
	import { page } from "$app/stores";

    export let href: string | undefined = undefined;
    export let prefix: string | undefined = href;
    export let tooltip: string;

    export let active: boolean | undefined = undefined;

    $: active = prefix ? ($page.url.pathname.startsWith(prefix)) : false;
</script>

<div class="
    tooltip tooltip-right
    w-full
    {$$props.class??""}
" class:active={active} data-tip={tooltip}>
    {#if href}
        <a
            {href}
            class="
                inline-flex items-center justify-center
                text-neutral-700 hover:text-neutral-300 transition-all duration-300
                flex-none {$$props.elClass}
            "
            class:active={active}
            on:click
        >
            <div class="w-full h-full max-w-[40px]">
                <slot {active} />
            </div>
        </a>
    {:else}
        <button
            class="
                inline-flex items-center justify-center
                text-neutral-700 hover:text-neutral-300 transition-all duration-300
                flex-none {$$props.elClass}
            "
            class:active={active}
            on:click
        >
            <div class="w-full h-full max-w-[32px]">
                <slot {active} />
            </div>
        </button>
    {/if}
</div>

<style lang="postcss">
    a, button {
        @apply py-2.5 px-2 sm:px-4 cursor-pointer w-full;
        @apply max-sm:px-3 max-sm:pt-3;
    }

    a.active, button.active {
        @apply text-accent2;
    }

    .tooltip {
        @apply sm:border-r-4;
        @apply max-sm:border-t-4;
        @apply border-transparent;
    }

    .tooltip.active {
        @apply border-accent2;

    }

    .button-view {
        @apply sm:bg-accent2/20 sm:rounded-2xl;
        @apply sm:hover:bg-accent2;
        @apply sm:border sm:border-accent2/30;
        @apply sm:w-14;
    }

    .button-view a {
        @apply sm:text-white p-3;
    }

    .highlight {
        @apply !bg-accent2 p-2 rounded-2xl text-white;
    }
</style>