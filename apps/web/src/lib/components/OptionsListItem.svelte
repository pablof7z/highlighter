<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
	import { page } from "$app/stores";
	import { NavigationOption } from "../../app";

    export let option: NavigationOption;
    export let value: string;
    export let collapsed;

    let active = false;
    let el: HTMLElement;

    $: {
        active = (value === (option.value || option.name) || $page.url.pathname === option.href);
        // scroll into view
        if (active) {
            el?.scrollIntoView({ block: "center" });
        }

    }

    function clicked() {
        if (option.fn) {
            option.fn();
        }
    }
</script>

<a
    bind:this={el}
    href={option.href}
    class="
        snap-center {option.class??""}
        sm:px-0 cursor-pointer
        max-sm:!py-4
        group
        sm:rounded-full
        w-fit
        flex-none
        
        flex flex-row items-center

        {collapsed ?
            "!h-16 !w-16" :
            "max-md:!h-16 max-md:!w-16"
        }
        
        {option.premiumOnly ? "premium" : ""}
    "
    on:click={clicked}
    class:active={active}
>
    {#if option.icon}
        <svelte:component this={option.icon}
            class="
                flex-none
                z-[20]
                w-6 h-6 inline
                {
                    collapsed ?
                        "sm:w-10 sm:h-10 rounded-full" :
                        "sm:w-8 sm:h-8"
                }
            "
            weight="light"
        />
    {/if}
    <span class="sm:hidden
    {collapsed ?
        "group-hover:inline group-hover:absolute group-hover:pl-12 group-hover:bg-base-200 group-hover:text-white group-hover:px-6 group-hover:py-2 group-hover:rounded-full group-hover:z-[19]"
        :
        "lg:inline"
        }
    ">
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
        @apply sm:text-lg p-2 px-4;
        @apply max-sm:w-fit;
        @apply text-base-100-content;
        @apply max-sm:border-b-4 max-sm:border-base-300 max-sm:rounded-b-none;
    }

    a.active, a:hover {
        @apply bg-base-200 text-white;
        @apply max-sm:border-accent2;
        @apply max-sm:bg-base-300;
    }
</style>