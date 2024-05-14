<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import HorizontalOptionsListItem from "./HorizontalOptionsListItem.svelte";
	import { NavigationOption } from "../../app";

    const dispatch = createEventDispatcher();

    export let options: NavigationOption[] = [];
    export let value: string = "";
</script>

<div class="
    justify-start items-start inline-flex whitespace-nowrap w-full
    border-t border-base-300
">
    <div class="
        lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}
        snap-x snap-mandatory
        overflow-x-auto max-w-[100vw]
        scrollbar-hide
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
                    on:click={(e) => {
                        if (!option.href) {
                            e.preventDefault();
                        }
                        dispatch("changed", { value: option.name });
                        value = option.name;
                    }}
                />
            {/if}
        {/each}
    </div>
</div>

