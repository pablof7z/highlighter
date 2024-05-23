<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
	import { page } from "$app/stores";
	import { NavigationOption } from "../../app";
    import { appMobileView } from "$stores/app";
	import { Chip } from "konsta/svelte";
	import { goto } from "$app/navigation";
	import { createEventDispatcher } from "svelte";

    export let option: NavigationOption;
    export let value: string = "";

    const dispatch = createEventDispatcher();

    let active = false;
    let el: HTMLElement;

    $: {
        active = (value === (option.value || option.name) || $page.url.pathname === option.href);
        // scroll into view
        if (active) {
            const isInView = el?.offsetLeft < el?.scrollLeft;

            if (isInView) el?.scrollIntoView({ block: "end"  });
        }

    }
</script>
{#if $appMobileView}
    <button class="
        flex flex-row items-center
        py-1 !h-auto
        !rounded-none
        !mx-0 !px-2
        {$$props.class??""}
        {option.class??""}
    " on:click={() => {
        dispatch("click");
        if (option.href) goto(option.href);
    }}>
        {#if option.icon}
            <svelte:component this={option.icon} class="w-5 h-5 inline mr-2" {...option.iconProps??{}} />
        {/if}
        {#if option.name}
            <span class="transition-all duration-300 { active ? "text-2xl font-bold text-white" : "text-base text-zinc-500"}">
                {option.name}
            </span>
        {/if}
    </button>
{:else}
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
        <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
    {/if}
    <span class="" class:hidden={!option.name}>
        {option.name}
        {#if option.premiumOnly}
            <span class="text-accent2">
                <CrownSimple class="w-5 h-5 ml-2 lg:w-fit lg:h-fit inline" weight="fill" />
            </span>
        {/if}
    </span>
</a>
{/if}

<style>
    a {
        @apply rounded-full;
        @apply justify-start items-center gap-2 flex;
        @apply text-base font-normal;
        @apply transition-all duration-100;
        @apply p-2 px-4;
        @apply w-fit;
        @apply text-base-100-content;
        @apply bg-base-200;
    }

    a.active {
        @apply font-bold;
        @apply bg-base-300 text-white;
        @apply inset-4;
    }
</style>