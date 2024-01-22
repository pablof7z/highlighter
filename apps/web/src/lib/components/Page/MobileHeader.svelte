<script lang="ts">
	import Input from '$components/Forms/Input.svelte';
	import { ArrowLeft, CaretLeft, MagnifyingGlass } from "phosphor-svelte";

    export let title: string | undefined = undefined;
    export let backButton: string;
    export let backTitle: string | undefined = undefined;

    let hasThreeColumns = false;

    $: hasThreeColumns = !!backButton && !!title && !!$$slots.button;
</script>

<div class="fixed sm:hidden flex flex-row items-center justify-between w-full px-6 h-16 top-0 z-50 mobile-nav left-0 {$$props.class??""}">
    {#if backButton}
        <a href={backButton} class="flex flex-row items-center gap-4 justify-between sm:hidden max-sm:w-1/5 absolute">
            <h1 class="grow shrink basis-0 text-white font-semibold flex flex-row items-center gap-2 text-left max-sm:text-lg sm:text-2xl whitespace-nowrap">
                <span class="flex flex-row items-center gap-1 flex-nowrap w-full font-normal">
                    <CaretLeft class="w-5 h-5 text-white" />
                    {#if backTitle}
                        <span class="text-base max-w-[60px] truncate">
                            {backTitle}
                        </span>
                    {/if}
                </span>
            </h1>
        </a>
    {/if}

    {#if title}
        <h1 class="max-sm:w-full max-sm:text-center flex-grow whitespace-nowrap flex items-center justify-center">
            <div class="
                {$$slots.button ? "max-w-[50vw]" : "max-w-[70vw]"}
                truncate flex-grow text-center w-full
            ">
                {title}
            </div>
        </h1>
    {/if}

    {#if $$slots.button}
        <div class="flex flex-row items-center gap-4 max-sm:w-1/5 justify-end absolute right-6">
            <slot name="button" />
        </div>
    {/if}
</div>
<div class="sm:hidden h-20"></div>

<style lang="postcss">
    h1 {
        @apply text-white font-semibold sm:text-2xl text-lg;
    }
</style>