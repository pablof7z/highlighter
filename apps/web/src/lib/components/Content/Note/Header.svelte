<script lang="ts">
	import { getReplyTag, getRootTag, NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import * as Event from "$components/Event";
    import HeaderShell from "$components/Content/HeaderShell.svelte";
	import ItemViewZaps from '$components/Event/ItemView/ItemViewZaps.svelte';
    import ContentToolbar from "$components/Content/Toolbar.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import { layout } from "$stores/layout";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import LoadEvent from "$components/Event/LoadEvent.svelte";

    export let event: NDKEvent;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    $layout.title = "Thread";
    $layout.sidebar = false;

    let showToolbar = false;
    let hasZaps = false;

    const replyTag = getRootTag(event);
    
</script>

{#if replyTag}
    <LoadEvent tag={replyTag} {event} let:event>
        {event?.id}
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
    <Event.Header {event} {userProfile} />

    <EventContent ndk={$ndk} {event} class="text-xl" />

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
