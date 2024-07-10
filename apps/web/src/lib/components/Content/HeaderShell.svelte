<script lang="ts">
	import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { inview } from "svelte-inview";

    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    
    export let skipSummary = false;
    export let skipImage = false;
    export let event: NDKEvent;

    export let title: string | false;
    export let zaps = false;
    export let toolbar = false;

    export let maxImageHeight = "max-h-[20rem]";
</script>

<div class="
    flex flex-col gap-4 {(!skipImage) ? '' : ""}
    {$$props.class??""}
" use:inview on:inview_change>
    {#if !skipImage}
        <div class="{maxImageHeight} overflow-clip flex">
            <slot name="image" />
        </div>
    {/if}
    <div class="flex flex-col gap-2">
        <div class="self-stretch text-foreground max-sm:text-xl text-4xl font-semibold responsive-padding" class:hidden={title === false}>
            <slot name="title" />
        </div>
        <div class="responsive-padding text-base text-foreground/70 font-normal lg:max-h-[10rem] overflow-y-auto scrollbar-hide" class:hidden={skipSummary}>
            <slot name="summary" />
        </div>

        <slot />

        {#if !isPreview}
            <div
                class="flex flex-col w-full divide-border border-y border-border"
                class:border-y={zaps || toolbar}
                class:divide-y={zaps && toolbar}
            >
                <slot name="zaps" />
                <slot name="toolbar" />
            </div>
        {/if}
    </div>
</div>