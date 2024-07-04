<script lang="ts">
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { NavigationOption } from "../../../../app";

    export let event: NDKEvent | undefined = undefined;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let skipImage = false;
    export let navigationOptions: NavigationOption[] | undefined = undefined;
</script>

<div dir="auto" class="w-full flex flex-col max-sm:max-w-screen overflow-x-clip">
    <div class="
        flex flex-col gap-4 {($$slots.image && !skipImage) ? '' : ""}
        {$$props.class??""}
    ">
        {#if !skipImage}
            <div class="max-h-[20rem] overflow-clip flex">
                <slot name="image" />
            </div>
        {/if}
        <div class="flex flex-col gap-2">
            {#if $$slots.title}
                <div class="self-stretch text-foreground max-sm:text-3xl text-4xl font-semibold responsive-padding ">
                    <slot name="title" />
                </div>
            {/if}
            <div class="responsive-padding text-xl text-foreground/70 font-normal lg:max-h-[10rem] overflow-y-auto scrollbar-hide" class:hidden={!$$slots.summary}>
                <slot name="summary" />
            </div>

            {#if !isPreview}
                {#if $$slots.zaps}
                    <slot name="zaps" />
                {/if}
                {#if $$slots.toolbar}
                    <slot name="toolbar" />
                {/if}
            {/if}


            <!-- {#if $$slots.tags}
                <slot name="tags" />
            {/if}
             -->
        </div>
    </div>

    <div class="
        flex-col justify-start items-center gap-10 flex w-full max-sm:px-4 relative font-serif !text-3xl
        border-border border-t
    ">
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
