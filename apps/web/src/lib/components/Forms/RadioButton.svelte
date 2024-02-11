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
    class:selected>
    <button class="text-white text-base font-medium flex flex-row gap-2 items-center justify-between w-full {$$props.class??""}" on:click={onClick}>
        <div class="flex flex-row items-start w-full">
            <div class="flex flex-row gap-2 justify-stretch items-start w-full">
                <div class="flex flex-col items-start grow w-full">
                    <slot />
                    <div class="text-neutral-500">
                        <slot name="description" />
                    </div>
                </div>

                <Check class="text-white {!selected ? 'hidden' : ''}" />
            </div>
        </div>
    </button>
</div>

<style lang="postcss">
    button {
        @apply border border-base-300 p-4 rounded-xl;
        @apply self-stretch !rounded-box justify-between items-start flex-col inline-flex h-full bg-black/80;
        @apply flex flex-col text-neutral-300
    }

    .container {
        @apply w-full;
        @apply !rounded-box bg-white/10;
        padding: 1px;
    }

    .container.selected {
        background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488ff 0%, #7092A0ff 100%);
    }
</style>