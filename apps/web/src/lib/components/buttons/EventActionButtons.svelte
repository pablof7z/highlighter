<script lang="ts">
	import { NDKKind, type NDKEvent, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import ReactButton from "./ReactButton.svelte";
	import BoostButton from "./BoostButton.svelte";
    import { createEventDispatcher, onDestroy } from "svelte";
	import { ChatCircle } from "phosphor-svelte";
	import { derived } from "svelte/store";
	import { ndk } from "$stores/ndk.js";
	import CurationButton from "./CurationButton.svelte";
	import { mainContentKinds } from "$utils/event";

    const dispatch = createEventDispatcher();

    export let event: NDKEvent;
    const eventKind = event.kind!;

    const taggedEvents = $ndk.storeSubscribe(
        { kinds: [
            NDKKind.GroupReply,
            NDKKind.Reaction,
            NDKKind.GenericRepost
        ], ...event.filter() },
        { subId: "tagged-events", groupable: true, groupableDelay: 50000, closeOnEose: false }
    )

    const replies = derived(taggedEvents, ($taggedEvents) => {
        return $taggedEvents.filter(e => e.kind === NDKKind.GroupReply);
    });

    const reposts = derived(taggedEvents, ($taggedEvents) => {
        return $taggedEvents.filter(e => e.kind === NDKKind.GenericRepost);
    });

    const reactions = derived(taggedEvents, ($taggedEvents) => {
        return $taggedEvents.filter(e => e.kind === NDKKind.Reaction);
    });

    onDestroy(() => {
        taggedEvents.unsubscribe();
    });
</script>

<div class="grow shrink basis-0 flex-col justify-start items-end gap-0.5 inline-flex">
    <div class="justify-start items-start gap-3 inline-flex">
        {#if mainContentKinds.includes(eventKind)}
            <CurationButton {event} />
        {/if}

        <ReactButton {event} />

        <button class="w-7 h-7 relative" on:click|stopPropagation|preventDefault={() => dispatch("comment")}>
            <ChatCircle class="w-7 h-7" weight="regular" />
        </button>

        <BoostButton {event} />
    </div>
    {#if $reactions.length > 0 || $replies.length > 0 || $reposts.length > 0}
        <div class="self-stretch text-right text-white text-opacity-60 text-sm font-normal leading-6">
            {#if ($reactions.length > 0)}
                {$reactions.length} reactions
            {/if}

            {#if ($replies.length > 0)}
                {$replies.length} replies
            {/if}

            {#if ($reposts.length > 0)}
                {$reposts.length} boosts
            {/if}
        </div>
    {/if}
</div>