<script lang="ts">
    import { createEventDispatcher } from "svelte";
    import type {Option} from "./option";
	import OptionsListItem from "./OptionsListItem.svelte";

    const dispatch = createEventDispatcher();

    export let options: Option[] = [];

    export let value: string = "";
    export let name: string = "this user";
</script>

<div class="justify-start items-start inline-flex whitespace-nowrap w-full">
    <div class="
        lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}
        snap-x snap-mandatory
        max-sm:overflow-x-auto max-sm:max-w-[100vw]
    ">
        {#each options as option (option.id ?? option.name)}
            {#if option.name === '-------'}
                <div class="
                    w-0.5 h-6 lg:w-full lg:h-[1px] bg-base-300 mx-2 lg:my-4
                "></div>
            {:else if option.component}
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
                    option={option}
                    value={value}
                    on:click={() => dispatch("changed", { value: option.name })}
                />
            {/if}
        {/each}
    </div>
</div>

