<script lang="ts">
	import Box from "$components/PageElements/Box.svelte";
    import { debounce } from "@sveu/shared";
	import { Question } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    export let loading = false;
    export let value: string | number | undefined;
    export let label: string;
    export let open: string | undefined = undefined;

    let valueRender: string | number | undefined = value;

    const updateValue = debounce((v: string | number) => {
        valueRender = v;
    }, 0.1);

    $: {
        if (value !== undefined) { updateValue(value); }
    }

    let showInfo = false;
    $: showInfo = open === label;

    function toggleOpen() {
        if (showInfo) {
            open = undefined;
        } else if ($$slots.default) {
            open = label;
            setTimeout(() => {
                document.addEventListener("click", () => {
                    open = undefined;
                }, { once: true });
            }, 100)
        }
    }
</script>

{#if !open || open === label}
    <div class="snap-center">
        <Box class={$$slots.default ? "hover:bg-white/10 transition-all duration-300" : ""} innerClass="!flex-row items-center px-6 {$$props.class??""}">
            <button class="flex flex-col items-center gap-2" on:click={toggleOpen}>
                <h1>
                    {#if loading || valueRender === undefined}
                        <div class="loading loading-lg"></div>
                    {:else}
                        {valueRender}
                    {/if}
                </h1>
                <span class="gradient-text">
                    {label}
                    {#if $$slots.default}
                        <Question class="inline ml-1 text-neutral-500" size="1.5rem" />
                    {/if}
                </span>
            </button>

            {#if showInfo}
                <div class="w-full">
                    <slot />
                </div>
            {/if}
        </Box>
    </div>
{/if}

<style lang="postcss">
    h1 {
        @apply text-5xl font-black mb-0;
    }

    span {
        @apply font-medium text-base text-center whitespace-nowrap;
    }
</style>