<script lang="ts">
	import { CaretLeft } from "phosphor-svelte";
    import SearchBar from "./SearchBar.svelte";

    export let title: string;
    export let back: string | undefined = undefined;
    export let marginClass = "w-full";
</script>


<div class="
    flex flex-row justify-between items-center mobile-container mobile-nav
    z-50
    w-full
    max-sm:p-4
">
    <div class="
        w-full flex items-center {marginClass}
        {$$props.class??""}
    ">
        {#if back}
            <a href={back} class="flex flex-row items-center gap-4 justify-between sm:hidden max-sm:w-1/5 absolute">
                <div class="grow shrink basis-0 text-white font-semibold font-['Inter Display'] flex flex-row items-center gap-2 text-left max-sm:text-lg sm:text-2xl">
                    <span class="flex flex-row items-center gap-1 flex-nowrap w-full font-normal">
                        <CaretLeft class="w-5 h-5 text-white" />
                    </span>
                </div>
            </a>
        {/if}

        <div
            class="flex flex-row w-full relative items-center"
            class:has-back-button={!!back}
        >
            <h1 class="absolute ml-6 flex-none z-50 max-sm:hidden">
                {title}
            </h1>

            <div class={marginClass}>
                <SearchBar />
            </div>

            {#if $$slots.right}
                <div class="
                    flex
                    justify-end
                ">
                    <slot name="right" />
                </div>
            {/if}
        </div>
    </div>
</div>

<div class="h-16"></div>

<style lang="postcss">
    .has-back-button {
        @apply pl-5;
    }

    h1 {
        @apply text-white text-2xl font-semibold text-center whitespace-nowrap truncate;
    }

    .mobile-container {
        @apply fixed border-b border-base-300 max-sm:w-full max-sm:left-0 max-sm:top-0 h-16;
    }
</style>