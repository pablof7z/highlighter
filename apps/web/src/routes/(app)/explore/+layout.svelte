<script lang="ts">
	import { MagnifyingGlass } from 'phosphor-svelte';
	import Input from '$components/Forms/Input.svelte';

</script>

<div class="flex flex-col w-full">
    <div class="border-b border-base-300 flex flex-row items-center justify-between gap-8 p-6 relative">
        <h1 class="2xl:absolute">
            Discover
        </h1>

        <div class="flex flex-col gap-6 w-full mx-auto sm:px-4 relative max-w-3xl">
            <MagnifyingGlass class="absolute top-1/2 left-8 transform -translate-y-1/2 w-6 h-6 text-neutral-500" />
            <Input
                color="black"
                label="Search"
                placeholder="Search or enter a URL to highlight"
                class="grow basis-0 sm:!bg-base-200 border-none font-normal pl-14 placeholder:!text-neutral-500 !rounded-full !text-neutral-300"
            />
        </div>
    </div>

    <slot />
</div>

<style lang="postcss">
    h1 {
        @apply text-white font-semibold text-2xl;
    }
</style>