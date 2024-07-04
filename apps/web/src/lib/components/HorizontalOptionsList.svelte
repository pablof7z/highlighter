<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import HorizontalOptionsListItem from "./HorizontalOptionsListItem.svelte";
	import { NavigationOption } from "../../app";
    import * as Tabs from "$lib/components/ui/tabs";

    const dispatch = createEventDispatcher();

    export let options: NavigationOption[] = [];
    export let value: string = "";
    export let tabs = false;
</script>

{#if options}

{#if tabs}
    <Tabs.Root bind:value class={$$props.class??""}>
        <Tabs.List>
            {#each options as option, i (option.id ?? option.name ?? option.href)}
                <Tabs.Trigger
                    value={option.value ?? option.name ?? option.href ?? i.toString()}
                    class="gap-2"
                >
                    {#if option.icon}
                        <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
                    {/if}
                    {#if option.name}
                        <span>
                            {option.name}
                        </span>
                    {/if}
                </Tabs.Trigger>
            {/each}
        </Tabs.List>
    </Tabs.Root>
{:else}
    <div class="
        justify-start items-start inline-flex whitespace-nowrap w-full
    ">
        <div class="
            lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}
            overflow-x-auto max-w-[100vw]
            scrollbar-hide gap-2
            transition-all duration-300
        
        ">
            {#each options as option (option.id ?? option.name ?? option.href)}
                {#if option.component}
                    {#if !option.component.unstyled}
                        <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 items-center">
                            <div class="rounded-full p-[2px]" class:text-foreground={value === (option.value || option.name)}>
                                <svelte:component
                                    this={option.component.component}
                                    {...option.component.props??{}}
                                />
                            </div>
                        </div>
                    {:else}
                        <svelte:component
                            this={option.component.component}
                            {...option.component.props??{}}
                        />
                    {/if}
                {:else}
                    <HorizontalOptionsListItem
                        {option}
                        {value}
                        class={$$props.itemClass??""}
                        on:click={(e) => {
                            if (!option.href) {
                                e.preventDefault();
                            }
                            dispatch("changed", { value: option.name });
                            if (option.fn) option.fn();
                            value = option.name;
                        }}
                    />
                {/if}
            {/each}
        </div>
    </div>
{/if}
{:else}
    <div class="w-full flex justify-center items-center">
        <div class="text-base-100">No options available</div>
    </div>
{/if}