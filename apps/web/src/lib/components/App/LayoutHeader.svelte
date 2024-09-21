<script lang="ts">
	import { layout } from "$stores/layout";
	import HeaderLeftButton from "./HeaderLeftButton.svelte";
	import HeaderRightButton from "./HeaderRightButton.svelte";
    import * as Event from "$components/Event";
	import { page } from "$app/stores";
	import HomeButton from "./HomeButton.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import { goto } from "$app/navigation";
	import { Button } from "$components/ui/button";
	import { fade } from "svelte/transition";
	import { CaretDown } from "phosphor-svelte";
	import BackButton from "./Navigation/BackButton.svelte";
    import * as Groups from "$components/Groups";
	import { throttle } from "@sveu/shared";

    export let containerClass: string = "";
    export let scrollDir: 'up' | 'down' | undefined;
    export let scrollPercentage: number;

    export let collapseNavOptions = true;

    const changeShowNavOptions = throttle((value: boolean) => {
        collapseNavOptions = value;
    }, 10);

    $: {
        if ($layout.navigation && $layout.navigation.length > 1 && (scrollDir === 'down' && !$layout.forceShowNavigation)) {
            changeShowNavOptions(false);
        } else {
            changeShowNavOptions(true);
        }
    }
</script>

<div class="flex flex-row justify-between items-center h-full w-full gap-2">
    {#if $layout.header && $layout.header.component}
        <div class="w-full h-full flex flex-col">
            <svelte:component
                this={$layout.header.component}
                {...$layout.header.props}
                class={$$props.containerClass}
            />
        </div>
    {:else}
        <div class="flex flex-row items-stretch w-full py-2">
            <!-- {#if $layout.sidebar === false}
                {#if $page.url.pathname !== "/"}
                    <div class="fixed max-sm:hidden ml-2">
                        <HomeButton />
                    </div>
                {/if}
            {/if} -->
            
            <div
                class="
                    flex items-center justify-between px-2 mx-auto w-full {containerClass}
                "
            >
                <div class="flex flex-row gap-2 items-center w-full truncate">
                    {#if $layout.back !== undefined}
                        <BackButton />
                    {/if}

                    {#if $layout?.iconUrl}
                        <!-- svelte-ignore a11y-missing-attribute -->
                        <img src={$layout.iconUrl} class="w-8 h-8 rounded-full flex-none" />
                    {/if}

                    <div class="flex flex-col items-start">
                        {#if $layout?.title}
                            <div class="
                                flex flex-row
                                text-foreground
                                font-medium text-lg
                                gap-2
                                col-span-5
                                text-center
                                grow truncate
                            ">
                                <span class="truncate">{$layout?.title}</span>
                            </div>
                        {/if}

                        {#if $layout.event?.tagValue("h")}
                            <Groups.PublishedToPills event={$layout.event} />
                        {/if}
                    </div>
                </div>

                <!-- If we explicit options, we show that -->
                {#if $layout?.options}
                    <HeaderRightButton />
                {:else if $layout.navigation && collapseNavOptions}
                    <!-- <div in:fade>
                        <Button variant="accent" size="sm" class="rounded-full" on:click={(e) => $layout.forceShowNavigation = true }>
                            {#if ($layout.activeOption||$layout.navigation[0]).icon}
                                <svelte:component
                                    this={($layout.activeOption||$layout.navigation[0]).icon}
                                    class="w-6 h-6 mr-2"
                                    {...($layout.activeOption||$layout.navigation[0]).iconProps}
                                />
                            {/if}
                            {#if ($layout.activeOption||$layout.navigation[0]).name}
                                {($layout.activeOption||$layout.navigation[0]).name}
                            {/if}
                            <CaretDown size={16} class="ml-2" />
                        </Button>
                    </div> -->
                {:else if $layout.event}
                    <RelativeTime event={$layout.event} class="text-muted-foreground !text-sm ml-4 whitespace-nowrap mr-2" />
                    <Event.Dropdown
                        event={$layout.event}
                        on:delete={() => goto('/')}
                        on:delete:cancel={(e) => goto('/a/'+e.detail?.event?.encode())}
                    />
                {/if}
            </div>
        </div>
    {/if}
</div>