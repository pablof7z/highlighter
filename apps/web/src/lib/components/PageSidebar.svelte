<script lang="ts">
	import { CaretDown, Receipt } from "phosphor-svelte";

    export let title: string;
    export let open = false;

    function toggleOpen() {
        open = !open;
    }
</script>

<div class="
    max-sm:fixed max-sm:top-0 max-sm:left-0 max-sm:h-screen
    sm:w-[300px] sm:flex-none
">
    <div class="
        max-sm:w-full bg-base-100 max-sm:mobile-nav px-[var(--mobile-body-px)] py-2
        sm:w-[300px] sm:rounded-3xl sm:px-6 sm:pt-4 sm:pb-6
        border border-neutral-800 flex-col justify-start items-start gap-6 inline-flex shrink-0 {$$props.class??""}
    ">
        <div class="self-stretch justify-between items-center gap-6 inline-flex">
            <button
                class="flex flex-row items-center gap-4 justify-between"
                on:click={toggleOpen}
            >
                <div class="
                    grow shrink basis-0 text-white font-semibold font-['Inter Display']
                    flex flex-row items-center gap-2
                    max-sm:text-lg
                    sm:text-2xl
                ">
                    {title}
                </div>

                <div class="sm:hiddden transition-all duration-500 sm:hidden" class:rotate-180={open}>
                    <CaretDown class="w-5 h-5 text-white" />
                </div>
            </button>

            {#if $$slots.headerRight}
                <slot name="headerRight" />
            {/if}
        </div>

        <div
            class:max-sm:hidden={!open}
            class="
            max-sm:max-h-[50dvh]
            overflow-y-auto
            flex-col justify-center items-start gap-3 flex w-full
        ">
            <slot />
        </div>
    </div>
</div>