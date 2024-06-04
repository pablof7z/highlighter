<script lang="ts">
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let isFullVersion: boolean;
    export let isPreview = false;
</script>

<div dir="auto" class="w-full flex flex-col">
    <div class="max-sm:-mx-4 flex sm:relative {($$slots.image && !isPreview) ? 'max-sm:h-screen min-h-[20vh] sm:h-[30vh]' : "h-[10vh]"}">
        <div class="w-full h-full absolute top-0 left-0 bottom-0 right-0 z-1 overflow-hidden">
            <slot name="image" />
        </div>
        <div class="w-full flex flex-col gap-2 absolute bottom-0 z-5 p-4 bg-gradient-to-b from-transparent via-base-100 to-base-100 pt-10">
            {#if $$slots.title}
                <div class="self-stretch text-white text-4xl font-semibold">
                    <slot name="title" />
                </div>
            {/if}
            <div class="text-xl text-white/70 font-normal lg:max-h-[6rem] overflow-y-auto scrollbar-hide" class:hidden={!$$slots.summary}>
                <slot name="summary" />
            </div>

            {#if !isPreview && $$slots.zaps}
                <slot name="zaps" />
            {/if}

            {#if $$slots.tags}
                <slot name="tags" />
            {/if}
            
        </div>
    </div>

    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4 relative">
        {#if !isPreview}
            <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                <slot name="content" />

                {#if !isFullVersion}
                    <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                        <UpgradeButton {event} />
                    </div>
                {/if}
            </div>
        {:else}
            <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                <slot name="content" />
            </div>
        {/if}
    </div>
</div>