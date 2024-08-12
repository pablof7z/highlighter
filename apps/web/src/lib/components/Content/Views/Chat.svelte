<script lang="ts">
	import { NDKArticle, NDKEvent, NDKFilter, NDKTag } from "@nostr-dev-kit/ndk";
    import * as Chat from "$components/Chat";
	import { ndk } from "$stores/ndk";
	import { onDestroy } from "svelte";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import Name from "$components/User/Name.svelte";
	import { derived, Readable } from "svelte/store";
	import { getEventUrl } from "$utils/url";

    export let wrappedEvent: NDKEvent;

    // addHistory({ category: 'Chat', title: wrappedEvent.title ?? "Event" });

    const filters: NDKFilter[] = [
        { kinds: [1311], ...wrappedEvent.filter() }
    ]

    let title = (wrappedEvent as NDKArticle).title ?? "this event";

    let tags: NDKTag[] = wrappedEvent.referenceTags("root")
    if (wrappedEvent.dTag) {
        tags.push(["d", wrappedEvent.dTag])

        filters.push({ kinds: [1311], "#d": [wrappedEvent.dTag] })
    }



    let eosed = false;
    const events = $ndk.storeSubscribe(filters, {
        onEose: () => { eosed = true; }
    })

    onDestroy(() => {
        events.unsubscribe();
    })

    let focusedOnThisEntry = false;

    let chats: Readable<NDKEvent[]>;
    const aTag = wrappedEvent.tagId();

    $: if (focusedOnThisEntry) {
        chats = derived(events, ($events) => {
            return $events.filter(e => e.tagValue("a") === aTag);
        })
    } else {
        chats = events;
    }
</script>

<div class="bg-secondary text-muted-foreground text-sm p-3 -mt-3 mb-3">
    <p>
        This is a public chat about
        <span class="text-foreground">{title}</span>.
    </p>

    <p>
        This chat will
        <span class="text-foreground">not appear in the feed</span>
        of people who follow you.
    </p>
</div>

<Checkbox type="switch" bind:value={focusedOnThisEntry} class="py-3 border-y text-xs">
    <span class="text-muted-foreground">
        Only view chats about
        <Name pubkey={wrappedEvent.pubkey} />'s
        entry

    </span>
</Checkbox>

{#key chats}
    <Chat.Shell
        events={chats}
        {eosed}
        {tags}
        kind={1311}
        let:event
    >
        {#if event.tagValue("a") !== aTag}
            <div class="text-muted-foreground text-xs">
                This is about
                <Name pubkey={event.tagValue('p')} />'s entry
            </div>
        {/if}
    </Chat.Shell>
{/key}