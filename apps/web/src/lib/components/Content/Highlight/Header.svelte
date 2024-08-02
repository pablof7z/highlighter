<script lang="ts">
	import { getRootTag, NDKEvent, NDKHighlight, NDKUserProfile } from "@nostr-dev-kit/ndk";
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
	import HighlightBody from "$components/HighlightBody.svelte";
	import Footer from "./Footer.svelte";

    export let event: NDKHighlight;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    $layout.title = "Highlight";
    $layout.sidebar = false;
    $layout.event = event;
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

<HeaderShell
    title={false}
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
        <HighlightBody highlight={event} />
    </div>

    <div slot="zaps" class:hidden={!hasZaps}>
        <ItemViewZaps {event} bind:hasZaps class="py-3 responsive-padding" />
    </div>

    <div slot="toolbar" class="py-3" class:hi_dden={!showToolbar}>
        <ContentToolbar
            {event}
            {authorUrl}
            navOptions={
                [{ name: "Highlight", href: getEventUrl(event, authorUrl) },]
            }
            bind:showToolbar
        />
    </div>

    <slot />
</HeaderShell>