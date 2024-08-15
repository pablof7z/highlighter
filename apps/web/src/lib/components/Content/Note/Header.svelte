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
    import * as Card from "$components/ui/card";

    export let event: NDKEvent;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    $layout.title = "Thread";
    $layout.header = undefined;
    $layout.event = event;
    $layout.sidebar = false;
    $layout.footerInMain = true;
    $layout.headerCanBeTransparent = false;
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

<Card.Root class="bg-secondary p-4 flex flex-col gap-4">
    <Card.Header class="p-0">
        <Card.Title>
            <Event.Header
                {event}
                {userProfile}
                avatarSize="lg"
                nameClass="text-lg font-normal"

            />
        </Card.Title>
    </Card.Header>

    <Card.Content class="p-0">
        <EventContent
            ndk={$ndk}
            {event}
            class="text-lg"
            mediaCollectionComponent={MediaCollection}
            eventCardComponent={EmbeddedEventWrapper}
        />
    </Card.Content>

    <Card.Footer class="flex flex-col p-0 {!hasZaps ? 'hidden' : ""}">
        <ItemViewZaps {event} bind:hasZaps class="py-3 responsive-padding" />
    </Card.Footer>
</Card.Root>

<div class="my-2">
    <ContentToolbar
        {event}
        {authorUrl}
        bind:showToolbar
    />
</div>

<div class="discussion-wrapper">

<!-- <HeaderShell
    {userProfile}
    {authorUrl}
    skipSummary={true}
    skipImage={true}
    {event}
    {blossom}
    ignoreHeader
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
</HeaderShell> -->
</div>