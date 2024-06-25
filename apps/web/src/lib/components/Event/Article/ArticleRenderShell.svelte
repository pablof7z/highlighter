<script lang="ts">
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent | undefined = undefined;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let skipImage = false;
</script>

<div dir="auto" class="w-full flex flex-col max-sm:max-w-screen overflow-x-clip">
    <div class="
        flex relative {($$slots.image && !skipImage) ? 'max-sm:h-[90vh] min-h-[20vh] sm:h-[20rem] lg:h-[50vh]' : ""}
        {$$props.class??""}
    ">
        {#if !skipImage}
            <div class="w-full h-full absolute top-0 left-0 bottom-0 right-0 z-1 overflow-hidden">
                <slot name="image" />
            </div>
        {/if}
        <div class="
            responsive-padding
            flex flex-col gap-4 sm:gap-2 {!skipImage ? "absolute" : ""} left-0 right-0 bottom-0 z-5 p-4 bg-gradient-to-b from-transparent via-background to-background pt-10">
            {#if $$slots.title}
                <div class="self-stretch text-foreground text-4xl font-semibold">
                    <slot name="title" />
                </div>
            {/if}
            <div class="text-xl text-foreground/70 font-normal lg:max-h-[10rem] overflow-y-auto scrollbar-hide" class:hidden={!$$slots.summary}>
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

    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4 relative font-serif !text-3xl">
        {#if !isPreview}
            <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                <slot name="content" />

                {#if !isFullVersion && event}
                    <div class="absolute bottom-0 right-0 bg-gradient-to-t from-background to-transparent via-background/70 w-full h-2/3 flex flex-col items-center justify-center">
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