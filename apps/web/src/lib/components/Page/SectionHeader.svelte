<script lang="ts">

	import { ArrowLeft, CaretLeft, MagnifyingGlass } from "phosphor-svelte";

    export let title: string | undefined = undefined;
    export let showSearch = true;
    export let backButton: string | undefined = undefined;
</script>

<div class="border-b border-base-300 flex flex-row items-center justify-between px-6 py-4 relative {$$props.class??""}">
    {#if backButton}
        <a href={backButton} class="flex flex-row items-center gap-4 justify-between sm:hidden">
            <h1 class="grow shrink basis-0 text-white font-semibold flex flex-row items-center gap-2 text-left max-sm:text-lg sm:text-2xl">
                <span class="flex flex-row items-center gap-1 flex-nowrap w-full font-normal">
                    <CaretLeft class="w-5 h-5 text-white" />
                    Welcome
                </span>
            </h1>
        </a>

    {/if}

    {#if title}
        <h1 class="2xl:absolute max-sm:w-full max-sm:text-center">
            {title}
        </h1>
    {/if}
</div>

<style lang="postcss">
    h1 {
        @apply text-white font-semibold sm:text-2xl text-xl;
    }
</style>