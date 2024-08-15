<script lang="ts">
	import { page } from "$app/stores";
    import { cn } from "$lib/utils.js";
	import { NavigationOption } from "../../app";
	import { createEventDispatcher } from "svelte";
	import Button from "./ui/button/button.svelte";
    import * as Tooltip from "$lib/components/ui/tooltip";

    export let option: NavigationOption;
    export let value: string = "";

    const dispatch = createEventDispatcher();

    let active = false;
    let el: HTMLElement;

    let hrefPath: string | undefined;
    if (option.href && option.href.length > 5) {
        try {
            hrefPath = new URL(option.href).pathname;
        } catch {}
    }

    $: {
        active = (value === (option.value || option.name || option.id ) || $page.url.pathname === option.href);
        if (hrefPath) {
            active = $page.url.pathname === hrefPath || $page.url.toString().includes(option.href);
        }
        
        // scroll into view
        if (active) {
            const isInView = el?.offsetLeft < el?.scrollLeft;

            if (isInView) el?.scrollIntoView({ block: "end"  });
        }

    }
</script>

{#if option.tooltip}
    <Tooltip.Root>
        <Tooltip.Trigger class="{option.class??""}">
            <Button
                href={option.href}
                variant={active ? "default" : "secondary"}
                {...option.buttonProps??{}}
                on:click={() => {
                    dispatch("click");
                    value = option.value ?? option.name ?? "Untitled";
                }}
                class={cn('gap-2', option.buttonProps?.class)}
            >
                {#if option.button?.icon && option.button?.fn}
                    <Button variant="secondary" class="bg-background/20 hover:bg-background/20 rounded-full -ml-5 rounded-r-none p-0.5 px-3 mr-0.5"
                        on:click={(e) => { option.button?.fn(); e.preventDefault(); e.stopPropagation(); }}
                    >
                        <svelte:component this={option.button.icon} class="w-4 h-4" {...option.button.iconProps??{}} />
                    </Button>
                {/if}
                {#if option.icon}
                    <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
                {/if}
                {#if option.name}
                    <span class="max-sm:text-base {$$props.class??""}" class:hidden={!option.name}>
                        {option.name}
                    </span>
                {/if}

                {#if option.badge}
                    <span class="opacity-50 pl-2">
                        {option.badge}
                    </span>
                {/if}
            </Button>
        </Tooltip.Trigger>
        <Tooltip.Content>
            {option.tooltip}
        </Tooltip.Content>
    </Tooltip.Root>
{:else}
    <Button
        href={option.href}
        variant={active ? "default" : "secondary"}
        {...option.buttonProps??{}}
        on:click={() => {
            dispatch("click");
            value = option.value ?? option.name ?? "Untitled";
        }}
        class={cn('gap-2', option.buttonProps?.class)}
    >
        {#if option.button?.icon && option.button?.fn}
            <Button variant="secondary" class="bg-background/20 hover:bg-background/20 rounded-full -ml-5 rounded-r-none p-0.5 px-3 mr-0.5"
                on:click={(e) => { option.button?.fn(); e.preventDefault(); e.stopPropagation(); }}
            >
                <svelte:component this={option.button.icon} class="w-4 h-4" {...option.button.iconProps??{}} />
            </Button>
        {/if}
        {#if option.icon}
            <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
        {/if}
        {#if option.name}
            <span class="max-sm:text-base {$$props.class??""}" class:hidden={!option.name}>
                {option.name}
            </span>
        {/if}

        {#if option.badge}
            <span class="opacity-50 pl-2">
                {option.badge}
            </span>
        {/if}
    </Button>
{/if}