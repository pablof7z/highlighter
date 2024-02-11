<script lang="ts">
    import { getUserHighlights } from "$stores/user-view";
    import { createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();

    type Option = {
        value?: string;
        name: string;
        tooltip?: string;
        icon?: any;
        class?: string;
    };

    export let options: Option[] = [];

    export let value: string;
    export let name: string = "this user"

    const highlights = getUserHighlights();

    function clicked(option: Option) {
        value = option.value || option.name
        dispatch('changed', { value, ...option });
    }
</script>

<div class="justify-start items-start gap-4 inline-flex whitespace-nowrap max-sm:px-3">
    <div class="justify-start items-center gap-4 flex">
        {#each options as option (option.name)}
            <div class:tooltip={option.tooltip} data-tip={option.tooltip}>
                {#if option.class?.includes("gradient")}
                    <div
                        class="rounded-full p-[2px] bg-gradient"
                    >
                    <button
                        class="snap-center border-2 border-base-100 gradient {option.class??""}"
                        on:click={() => clicked(option)}
                        class:active={value === (option.value || option.name)}
                    >
                        {#if option.icon}
                            <svelte:component this={option.icon} class="w-5 h-5 mr-1 inline" />
                        {/if}
                        {option.name}
                    </button>
                    </div>
                {:else}
                    <div class="rounded-full p-[2px]" class:bg-white={value === (option.value || option.name)}>
                        <button
                            class="snap-center border-2 border-base-100 {option.class??""}"
                            on:click={() => clicked(option)}
                            class:active={value === (option.value || option.name)}
                        >
                            {#if option.icon}
                                <svelte:component this={option.icon} class="w-5 h-5 mr-1 inline" />
                            {/if}
                            {option.name}
                        </button>
                    </div>
                {/if}
            </div>
        {/each}
    </div>
</div>

<style>
    button {
        @apply px-4 py-2 rounded-full;
        @apply bg-zinc-800 bg-opacity-70 justify-start items-center gap-2 flex;
        @apply text-neutral-400 text-sm font-normal;
        @apply transition-all duration-100;
    }

    button:hover {
        @apply text-neutral-200;
    }

    button.active {
        @apply !bg-white !text-black;
    }

    button.gradient {
        @apply bg-zinc-800;
    }

    button.gradient.active {
        @apply !bg-base-100/40 !text-white !border m-[1px];
    }
</style>