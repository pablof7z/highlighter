<script lang="ts">
	import ItemViewZaps from "$components/Event/ItemView/ItemViewZaps.svelte";
	import { NDKArticle, NDKEvent, NDKHighlight, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, getContext, onMount } from "svelte";
	import { inview } from "svelte-inview";
	import { NavigationOption } from "../../../app";
	import HeaderShell from "./HeaderShell.svelte";
    import ContentToolbar from "./Toolbar.svelte";
	import { layout } from "$stores/layout";

    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;
    
    export let event: NDKEvent;

    export let image: string | undefined | false;
    export let title: string | false;
    export let summary: string | boolean;

    export let navOptions: NavigationOption[] = [];

    const dispatcher = createEventDispatcher();

    $layout.activeOption = navOptions[0];
    
    function titleViewChange(e) {
        const { inView } = e.detail;
        dispatcher("title:inview_change", inView);

        if (inView) {
            $layout.navigation = false;
        } else {
            $layout.header = undefined;
            $layout.navigation = navOptions;
        }
    }

    let hasZaps: boolean;
</script>

<HeaderShell
    isPreview={isPreview}
    userProfile={userProfile}
    authorUrl={authorUrl}
    skipSummary={!summary && !$$slots.summary}
    skipImage={image === false}
    event={event}
    title={title}
    {blossom}
    zaps={hasZaps}
>
    <svelte:fragment slot="image">
        {#if image !== false}
            <svelte:element
                this={image ? 'img' : 'div'}
                class="w-full object-cover bg-secondary max-h-[40vh]"
                {...(image ? { src: image } : {})}
            />
        {/if}
    </svelte:fragment>

    <div slot="title" use:inview on:inview_change={titleViewChange}>
        {title??"Untitled"}
    </div>

    <div slot="summary" class:hidden={!summary && !$$slots.summary}>
        {#if summary}
            <div class="text-xl">
                {summary}
            </div>
        {/if}
        {#if $$slots.summary}
            <slot name="summary" />
        {/if}
    </div>

    <div slot="zaps">
        {#if !isPreview}
            <ItemViewZaps {event} bind:hasZaps class="py-[var(--section-vertical-padding)] responsive-padding border-y border-border" />
        {/if}
    </div>

    <div slot="toolbar" class="py-[var(--section-vertical-padding)] border-b border-border mb-[var(--section-vertical-padding)]" class:hidden={isPreview}>
        {#if !isPreview}
            <ContentToolbar
                {event}
                {navOptions}
                {authorUrl}
                on:curate
            />
        {/if}
    </div>

    <slot />
</HeaderShell>
