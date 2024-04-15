<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
    import type { Option } from "./option";

    export let option: Option;
    export let value: string;

    let active = false;
    let el: HTMLElement;

    $: {
        active = (value === (option.value || option.name))
        // scroll into view
        if (active) {
            el?.scrollIntoView({ block: "center" });
        }

    }
</script>

<a
    bind:this={el}
    href={option.href}
    class="
        rounded-full
        snap-center {option.class??""}
        sm:px-0 cursor-pointer
        {active ? "max-sm:bg-white max-sm:text-black" : ""}
        {option.premiumOnly ? "premium" : ""}
    "
    on:click
    class:active={active}
>
    {#if option.icon}
        <svelte:component this={option.icon} class="w-6 xl:w-5 h-6 xl:h-5 inline" />
    {/if}
    <span class="sm:hidden xl:inline">
        {option.name}
        {#if option.premiumOnly}
            <span class="text-accent2">
                <CrownSimple class="w-5 h-5 ml-2 lg:w-fit lg:h-fit inline" weight="fill" />
            </span>
        {/if}
    </span>
</a>

<style>
    a {
        @apply justify-start items-center gap-2 flex;
        @apply text-sm font-normal;
        @apply transition-all duration-100;
        @apply sm:text-lg p-2 px-4;
        @apply max-sm:w-fit;
        @apply text-white/90;
        @apply max-sm:border-b-4 max-sm:border-base-300 max-sm:rounded-b-none;
    }

    a.active {
        @apply font-bold bg-zinc-900 text-white;
        @apply max-sm:border-accent2;
    }
</style>