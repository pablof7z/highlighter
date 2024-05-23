<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import HorizontalOptionsListItem from "./HorizontalOptionsListItem.svelte";
	import { NavigationOption } from "../../app";

    const dispatch = createEventDispatcher();

    export let options: NavigationOption[] = [];
    export let value: string = "";
</script>

{#if options}
<div class="
    justify-start items-start inline-flex whitespace-nowrap w-full
">
    <div class="
        lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}
        overflow-x-auto max-w-[100vw]
        scrollbar-hide
        transition-all duration-300
    ">
        {#each options as option (option.id ?? option.name)}
            {#if option.component}
                {#if !option.component.unstyled}
                    <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 p-1.5 items-center">
                        <div class="rounded-full p-[2px]" class:text-white={value === (option.value || option.name)}>
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
{:else}
    <div class="w-full flex justify-center items-center">
        <div class="text-base-100">No options available</div>
    </div>
{/if}