<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import OptionsListItem from "./OptionsListItem.svelte";
	import { NavigationOption } from "../../app";

    const dispatch = createEventDispatcher();

    export let options: NavigationOption[] = [];

    export let value: string = "";
    export let collapsed = false;
</script>

<div class="
    justify-start items-start inline-flex whitespace-nowrap w-full
    max-sm:border-t border-base-300
">
    <div class="
        lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}
        snap-x snap-mandatory
        max-sm:overflow-x-auto max-sm:max-w-[100vw]
        max-sm:scrollbar-hide
    ">
        {#each options as option (option.id ?? option.name)}
            {#if option.component}
                <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 p-1.5 items-center">
                    <div class="rounded-full p-[2px]" class:text-white={value === (option.value || option.name)}>
                        <svelte:component
                            this={option.component.component}
                            {...option.component.props??{}}
                        />
                    </div>
                </div>
            {:else}
                <OptionsListItem
                    {option}
                    {value}
                    {collapsed}
                    on:click={() => { dispatch("changed", { value: option.name }); value = option.name; }}
                />
            {/if}
        {/each}
    </div>
</div>

