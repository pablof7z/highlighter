<script lang="ts">
    import { createEventDispatcher } from "svelte";
    import type {Option} from "./option";
	import OptionsListItem from "./OptionsListItem.svelte";

    const dispatch = createEventDispatcher();

    export let options: Option[] = [];

    export let value: string = "";
    export let name: string = "this user";
</script>

<div class="
    justify-start items-start inline-flex whitespace-nowrap w-full
    max-sm:border-t border-base-300
">
    <div class="
        xl:justify-stretch xl:items-stretch items-end flex w-full {$$props.class??""}
        snap-x snap-mandatory
        max-sm:overflow-x-auto max-sm:max-w-[100vw]
        max-sm:py-1
    ">
        {#each options as option (option.id ?? option.name)}
            {#if option.name === '-------'}
                <div class="
                    w-0.5 h-6 xl:w-full xl:h-[1px] bg-base-300 mx-2 my-0
                "></div>
            {:else if option.component}
                <div class="max-xl:rounded-full transition-all duration-300 max-xl:hover:bg-white/10 p-1.5 items-center">
                    <div class="rounded-full p-[2px]" class:text-white={value === (option.value || option.name)}>
                        <svelte:component
                            this={option.component.component}
                            {...option.component.props??{}}
                        />
                    </div>
                </div>
            {:else}
                <OptionsListItem
                    option={option}
                    value={value}
                    on:click={() => dispatch("changed", { value: option.name })}
                />
            {/if}
        {/each}
    </div>
</div>

