<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
    import type { Option } from "./option";
	import { page } from "$app/stores";

    export let option: Option;
    export let value: string;

    let active = false;
    let el: HTMLElement;

    $: {
        active = (value === (option.value || option.name) || $page.url.pathname === option.href);
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
        snap-center {option.class??""}
        cursor-pointer
        {option.premiumOnly ? "premium" : ""}
    "
    on:click
    class:active={active}
>
    {#if option.icon}
        <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" />
    {/if}
    <span class="">
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
        @apply text-base font-normal;
        @apply transition-all duration-100;
        @apply p-2 px-4;
        @apply w-fit;
        @apply text-base-100-content;
        @apply border-b-4 border-transparent;
    }

    a.active {
        @apply font-bold;
        @apply border-accent2;
        @apply bg-base-300 text-white;
        @apply inset-4;
    }
</style>