<script lang="ts">
	import { getReplyTag, getRootTag, NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import * as Event from "$components/Event";
    import MediaCollection from '$components/Events/MediaCollection.svelte';
    import HeaderShell from "$components/Content/HeaderShell.svelte";
	import ItemViewZaps from '$components/Event/ItemView/ItemViewZaps.svelte';
    import ContentToolbar from "$components/Content/Toolbar.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import { layout } from "$stores/layout";
	import LoadEvent from "$components/Event/LoadEvent.svelte";
	import EmbeddedEventWrapper from "$components/Events/EmbeddedEventWrapper.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { goto } from "$app/navigation";
	import { getEventUrl } from "$utils/url";
	import Footer from "./Footer.svelte";

    export let event: NDKEvent;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    $layout.title = "Thread";
    $layout.sidebar = false;
    $layout.footerInMain = true;
    $: $layout.footer = {
        component: Footer,
        props: {
            event,
            userProfile
        }
    }

    let showToolbar = false;
    let hasZaps = false;

    const replyTag = getRootTag(event);
    
</script>

<div class="discussion-wrapper">
{#if replyTag}
    <LoadEvent tag={replyTag} {event} let:event={f}>
        {#if f}
            <EventWrapper
                event={f}
                compact
                on:open:note={() => goto(getEventUrl(f))}
                class="text-sm text-muted-foreground"
            />
        {/if}
    </LoadEvent>
{/if}

<HeaderShell
    {userProfile}
    {authorUrl}
    skipSummary={true}
    skipImage={true}
    {event}
    {blossom}
    zaps={hasZaps}
    toolbar={showToolbar}
>
    <div class="p-4 text-foreground">
        <Event.Header {event} {userProfile} />

        <EventContent
            ndk={$ndk}
            {event}
            class="text-xl"
            mediaCollectionComponent={MediaCollection}
            eventCardComponent={EmbeddedEventWrapper}
        />
    </div>

    <div slot="zaps" class:hidden={!hasZaps}>
        <ItemViewZaps {event} bind:hasZaps class="py-3 responsive-padding" />
    </div>

    <div slot="toolbar" class="py-3" class:hi_dden={!showToolbar}>
        <ContentToolbar
            {event}
            {authorUrl}
            bind:showToolbar
        />
    </div>

    <slot />
</HeaderShell>
</div>