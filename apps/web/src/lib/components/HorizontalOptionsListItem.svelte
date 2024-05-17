<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
	import { page } from "$app/stores";
	import { NavigationOption } from "../../app";
    import { appMobileView } from "$stores/app";
	import { Chip } from "konsta/svelte";
	import { goto } from "$app/navigation";
	import { createEventDispatcher } from "svelte";

    export let option: NavigationOption;
    export let value: string;

    const dispatch = createEventDispatcher();

    let active = false;
    let el: HTMLElement;

    $: {
        active = (value === (option.value || option.name) || $page.url.pathname === option.href);
        // scroll into view
        if (active) {
            const isInView = el?.offsetLeft < el?.scrollLeft;

            if (isInView) el?.scrollIntoView({ block: "center" });
        }

    }
</script>
{#if $appMobileView}
    <Chip class="
        m-0.5 !px-4 py-2 !h-auto
        !text-lg
        snap-center {option.class??""}
        { active ? "!bg-accent2 text-white" : ""}
    " onClick={() => {
        dispatch("click");
        if (option.href) goto(option.href);
    }}>
        {#if option.icon}
            <svelte:component this={option.icon} class="w-5 h-5 inline mr-2" {...option.iconProps??{}} />
        {/if}
        {option.name}
    </Chip>
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
    <span class="">
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