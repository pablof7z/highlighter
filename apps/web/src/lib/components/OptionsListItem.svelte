<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
    import type { Option } from "./option";

    export let option: Option;
    export let value: string;

    let active = false;

    $:  active = (value === (option.value || option.name))


</script>

    <a
        href={option.href}
        class="
            rounded-full
            snap-center w-full {option.class??""}
            sm:px-0 cursor-pointer
            hover:text-white
            {active ? "max-sm:bg-white max-sm:text-black lg:text-white" : "max-sm:bg-white/10"}
            {option.premiumOnly ? "premium" : ""}
        "
        on:click
        class:active={active}
    >
        {#if option.icon}
            <svelte:component this={option.icon} class="w-6 xl:w-5 h-6 xl:h-5 inline" />
        {/if}
        <span class="sm:hidden lg:inline">
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
        @apply text-lg p-2 px-4;
        @apply max-sm:w-fit;
    }

    a.active {
        @apply lg:!text-white font-bold lg:bg-white/10;
    }
</style>