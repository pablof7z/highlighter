<script lang="ts">
	import Input from '$components/Forms/Input.svelte';
	import { ArrowLeft, CaretLeft, MagnifyingGlass } from "phosphor-svelte";

    export let title: string | undefined = undefined;
    export let showSearch = true;
    export let backButton: string;
</script>

<div class="border-b border-base-300 flex flex-row items-center justify-between p-6 relative {$$props.class??""}">
    {#if backButton}
        <a href={backButton} class="flex flex-row items-center gap-4 justify-between sm:hidden">
            <div class="grow shrink basis-0 text-white font-semibold font-['Inter Display'] flex flex-row items-center gap-2 text-left max-sm:text-lg sm:text-2xl">
                <span class="flex flex-row items-center gap-1 flex-nowrap w-full font-normal">
                    <CaretLeft class="w-5 h-5 text-white" />
                    Welcome
                </span>
            </div>
        </a>

    {/if}

    {#if title}
        <h1 class="2xl:absolute max-sm:w-full max-sm:text-center">
            {title}
        </h1>
    {/if}

    {#if showSearch}
    <div class="flex flex-col gap-6 w-full mx-auto sm:px-4 relative max-w-3xl">
            <MagnifyingGlass class="absolute top-1/2 left-8 transform -translate-y-1/2 w-6 h-6 text-neutral-500" />
            <Input
                color="black"
                label="Search"
                placeholder="Search or enter a URL to highlight"
                class="grow basis-0 sm:!bg-base-200 border-none font-normal pl-14 placeholder:!text-neutral-500 !rounded-full !text-neutral-300"
            />
        </div>
    {/if}
</div>

<style lang="postcss">
    h1 {
        @apply text-white font-semibold sm:text-2xl text-xl;
    }
</style>