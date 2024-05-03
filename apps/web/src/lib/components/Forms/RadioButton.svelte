<script lang="ts">
	import { Check } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

    export let currentValue: string | undefined = undefined;
    export let value: string | undefined = undefined;

    const dispatch = createEventDispatcher();

    let selected: boolean;

    $: selected = currentValue === value;

    function onClick() {
        currentValue = value;
        dispatch("click", value);
    }
</script>

<div class="container"
    class:selected
>
    <button class="text-white text-base font-medium flex flex-row gap-2 items-center justify-between w-full {$$props.class??""}" on:click={onClick}>
        <div class="flex flex-row items-start w-full">
            <div class="flex flex-row gap-2 justify-stretch items-start w-full">
                <div class="flex flex-col items-start grow w-full">
                    <span><slot /></span>
                    <div>
                        <slot name="description" />
                    </div>
                </div>

                {#if !$$props.skipCheck}
                    <Check class="text-white {!selected ? 'hidden' : ''}" />
                {/if}
            </div>
        </div>
    </button>
</div>

<style lang="postcss">
    button {
        @apply px-4 py-3;
        @apply self-stretch justify-between items-start flex-col inline-flex h-full;
        @apply flex flex-col text-neutral-300
    }

    .container {
        @apply w-full overflow-clip;
    }

    .container.selected {
        @apply bg-white;
    }

    .container.selected span {
        @apply text-black;
    }
</style>