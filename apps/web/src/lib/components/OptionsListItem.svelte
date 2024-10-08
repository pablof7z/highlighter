<script lang="ts">
	import { page } from "$app/stores";
	import { NavigationOption } from "../../app";
    import Badge from "$components/ui/badge/badge.svelte";
    import * as Tooltip from "$lib/components/ui/tooltip";

    export let option: NavigationOption;
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

    function clicked() {
        if (option.fn) {
            option.fn();
        }
    }
</script>

<Tooltip.Root>
    <Tooltip.Trigger class="w-full">
        <a
            bind:this={el}
            href={option.href}
            class="
                snap-center {option.class??""}
                sm:px-0 cursor-pointer
                px-2 py-2
                group
                flex-none
                w-full
                
                flex flex-row items-center justify-center
                rounded relative
            "
            on:click={clicked}
            class:active={active}
        >
            {#if option.icon}
                <div class="flex flex-col items-center justify-center h-full w-full">
                    {#if option.badge}
                        <div class="indicator">
                            {#if option.badge === true}
                                <Badge variant="accent"></Badge>
                            {:else}
                                <Badge variant="accent" class="rounded-full w-5 h-5 flex items-center justify-center">{option.badge}</Badge>
                            {/if}
                        </div>
                    {/if}
                    <svelte:component this={option.icon}
                        class="
                            flex-none
                            w-9 h-9
                            inline
                            text-muted-foreground
                            group-hover:text-foreground
                            {option.class??""}
                        "
                        weight={active ? "light" : "thin"}
                    />
                </div>
            {/if}
            <!-- <span class="sm:hidden flex flex-row items-center
            {collapsed ?
                "group-hover:inline group-hover:absolute group-hover:pl-12 group-hover:bg-secondary group-hover:text-foreground group-hover:px-6 group-hover:py-2 group-hover:rounded-full group-hover:z-[999]"
                :
                "lg:inline"
                }
            ">
                {option.name}
            </span> -->
        </a>
    </Tooltip.Trigger>
    <Tooltip.Content>
        {option.tooltip??option.name}
    </Tooltip.Content>
</Tooltip.Root>

<style>
    a {
        @apply justify-start items-center gap-2 flex;
        @apply text-sm font-normal;
        @apply max-sm:border-b-4 max-sm:border-border max-sm:rounded-b-none;
    }

    a:hover {
        @apply bg-secondary text-secondary-foreground;
    }

    a.active {
        @apply bg-primary/10 text-secondary-foreground;
        @apply border border-border;
    }

    .indicator {
        @apply flex flex-col items-center justify-center absolute right-0 top-0;
    }
</style>