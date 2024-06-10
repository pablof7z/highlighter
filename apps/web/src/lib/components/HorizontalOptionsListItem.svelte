<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
	import { page } from "$app/stores";
	import { NavigationOption } from "../../app";
    import { appMobileView } from "$stores/app";
	import { goto } from "$app/navigation";
	import { createEventDispatcher } from "svelte";
	import { badgeVariants } from "./ui/badge";
	import Button from "./ui/button/button.svelte";

    export let option: NavigationOption;
    export let value: string = "";

    const dispatch = createEventDispatcher();

    let active = false;
    let el: HTMLElement;

    $: {
        active = (value === (option.value || option.name ) || $page.url.pathname === option.href);
        // scroll into view
        if (active) {
            const isInView = el?.offsetLeft < el?.scrollLeft;

            if (isInView) el?.scrollIntoView({ block: "end"  });
        }

    }
</script>
{#if $appMobileView && false}
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
            <span class="transition-all duration-300 { active ? "text-2xl font-bold text-foreground" : "text-base text-zinc-500"}">
                {option.name}
            </span>
        {/if}
    </button>
{:else}
    {#if option.href && false}
        <a
            bind:this={el}
            href={option.href}
            class="
                snap-center {option.class??""}
                {badgeVariants({ variant: active ? "default" : "secondary" })}
                sm:!p-1 sm:!px-3 !text-base gap-2
            "
            on:click
        >
            {#if option.icon}
                <svelte:component this={option.icon} weight="light" class="w-6 lg:w-5 h-6 lg:h-5 inline {active ? "text-primary-foreground" : "text-muted-foreground"}" {...option.iconProps??{}} />
            {/if}
            <span class="{active ? "font-bold text-primary-foreground" : "sm:!font-light font-normal text-muted-foreground"}" class:hidden={!option.name}>
                {option.name}
                {#if option.premiumOnly}
                    <span class="text-accent">
                        <CrownSimple class="w-5 h-5 ml-2 lg:w-fit lg:h-fit inline" weight="fill" />
                    </span>
                {/if}
            </span>
        </a>
    {:else}
        <Button
            forceNonMobile
            href={option.href}
            variant={active ? "default" : "secondary"}
            {...option.buttonProps??{}}
            on:click={() => {
                dispatch("click");
                if (option.fn) option.fn();
                value = option.value ?? option.name;
            }}
            class="gap-2"
        >
            {#if option.icon}
                <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
            {/if}
            {#if option.name}
                <span class="" class:hidden={!option.name}>
                    {option.name}
                    {#if option.premiumOnly}
                        <span class="text-accent">
                            <CrownSimple class="w-5 h-5 ml-2 lg:w-fit lg:h-fit inline mr-2" weight="fill" />
                        </span>
                    {/if}
                </span>
            {/if}
        </Button>
    {/if}
{/if}
