<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import OptionsListItem from "./OptionsListItem.svelte";
	import { NavigationOption } from "../../app";

    const dispatch = createEventDispatcher();

    export let options: NavigationOption[] = [];
    export let value: string = "";
</script>

<div class="
    justify-start items-start inline-flex whitespace-nowrap w-full
    max-sm:border-t border-border
">
    <div class="
        flex w-full {$$props.class??""}
        snap-x snap-mandatory
        max-sm:overflow-x-auto max-sm:max-w-[100vw]
        max-sm:scrollbar-hide
        items-center justify-center
    ">
        {#each options as option (option.id ?? option.name)}
            {#if option.component}
                <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 p-1.5 items-center">
                    <div class="rounded-full p-[2px]" class:text-foreground={value === (option.value || option.name)}>
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
                    on:click={() => { dispatch("changed", { value: option.name }); value = option.name; }}
                />
            {/if}
        {/each}
    </div>
</div>

