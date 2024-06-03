<script lang="ts">
    import { debugMode } from "$stores/session";
	import { encodeTag } from "$utils/event";
    import { NDKEvent, NDKSubscriptionCacheUsage, NDKSubscriptionOptions, getReplyTag, getRootEventId, getRootTag } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher } from "svelte";

    export let event: NDKEvent;
    export let urlPrefix: string = "/e/";
    export let isNoop: boolean | undefined = false;

    let rootEvent: NDKEvent | undefined | null | "not-fetched" = "not-fetched";
    let replyToEvent: NDKEvent | undefined | null | "not-fetched" = "not-fetched";

    const dispatch = createEventDispatcher();

    const subOpts: NDKSubscriptionOptions = {
        groupable: true,
        subId: 'view-conversation',
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE
    }

    const rootTag = getRootTag(event);
    let rootEncode = rootTag ? encodeTag(rootTag) : "";

    const replyTag = getReplyTag(event);

    if (rootTag ?? replyTag) {
        $ndk.fetchEventFromTag((replyTag ?? rootTag)!, subOpts).then((e: NDKEvent | null) => {
            replyToEvent = e;
        });
    }
    
    $: isNoop = false;// !(replyToEvent instanceof NDKEvent || rootTag);

    function clicked(event: NDKEvent, e: Event) {
        dispatch("click", {event, originalEvent: e});
    }
</script>

<div class="flex flex-row gap-4 truncate ">
    {#if replyToEvent instanceof NDKEvent}
        <a href="{urlPrefix}{replyToEvent.encode()}" on:click={(e) => clicked(replyToEvent, e)}>
            reply to
            @<Name npubMaxLength={12} user={replyToEvent.author} attribute="name" />
        </a>
    {/if}
    
    {#if rootEncode && ((rootTag && rootTag?.[1] !== replyTag?.[1]) || !(replyToEvent instanceof NDKEvent))}
        <a href="{urlPrefix}{rootEncode}">
            View conversation
        </a>
    {/if}
</div>

{#if $debugMode}
    <div>
        {JSON.stringify(event.tags)}
    </div>
{/if}

<style lang="postcss">
    a {
        @apply text-sm text-accent;
    }
</style>