<script lang="ts">
    import { CrownSimple } from "phosphor-svelte";
	import { page } from "$app/stores";
	import { NavigationOption } from "../../app";
    import { appMobileView } from "$stores/app";
	import { goto } from "$app/navigation";
	import { createEventDispatcher } from "svelte";
	import { badgeVariants } from "./ui/badge";
	import Button from "./ui/button/button.svelte";
    import * as Tooltip from "$lib/components/ui/tooltip";


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

<Tooltip.Root>
    <Tooltip.Trigger>
        <Button
            forceNonMobile={true}
            href={option.href}
            variant={active ? "accent" : "secondary"}
            {...option.buttonProps??{}}
            on:click={() => {
                dispatch("click");
                value = option.value ?? option.name ?? "Untitled";
            }}
            class="gap-2 !rounded-full"
        >
            {#if option.icon}
                <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
            {/if}
            {#if option.name}
                <span class="max-sm:text-base" class:hidden={!option.name}>
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
        {option.tooltip??option.name}
    </Tooltip.Content>
</Tooltip.Root>