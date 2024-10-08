<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import HorizontalOptionsListItem from "./HorizontalOptionsListItem.svelte";
	import { NavigationOption } from "../../app";
    import * as Tabs from "$lib/components/ui/tabs";
	import { goto } from "$app/navigation";

    const dispatch = createEventDispatcher();

    export let options: NavigationOption[] = [];
    export let activeOption: NavigationOption | null = null;
    export let value: string | undefined | false = undefined;
    export let tabs = false;

    function optionId(option: NavigationOption, index: number) {
        return option.id ?? option.name ?? option.href ?? index.toString();
    }

    $: if (value === undefined && options.length > 0) {
        if (value !== false) value = optionId(options[0], 0);
    }

</script>

{#if options}

{#if tabs}
    <Tabs.Root bind:value class={$$props.class??""}>
        <Tabs.List>
            {#each options as option, i (option.id ?? option.name ?? option.href)}
                <Tabs.Trigger
                    value={option.value ?? option.name ?? option.href ?? i.toString()}
                    class="gap-2"
                    on:click={(e) => { if (option.href) goto(option.href); }}
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
        justify-start items-start inline-flex whitespace-nowrap w-full scrollbar-hide
    ">
        <div class="
            lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}
            overflow-x-auto max-w-[100vw]
            scrollbar-hide gap-2
            transition-all duration-300
        
        ">
            {#each options as option, index (optionId(option, index))}
                {#if option.component}
                    {#if !option.component.unstyled}
                        <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 items-center">
                            <div class="rounded-full p-[2px]" class:text-foreground={value === optionId(option, index)}>
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
                        {index}
                        class={$$props.itemClass??""}
                        on:click={(e) => {
                            if (!option.href) {
                                e.preventDefault();
                            }
                            activeOption = option;
                            dispatch("changed", { value: option.name, option });
                            if (option.fn) option.fn();
                            value = optionId(option, index);
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