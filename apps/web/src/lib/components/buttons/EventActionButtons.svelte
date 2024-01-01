<script lang="ts">
	import { NDKKind, type NDKEvent, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import ReactButton from "./ReactButton.svelte";
	import BoostButton from "./BoostButton.svelte";
    import { createEventDispatcher } from "svelte";
	import { ChatCircle } from "phosphor-svelte";
	import { derived } from "svelte/store";
	import { ndk } from "@kind0/ui-common";

    const dispatch = createEventDispatcher();

    export let event: NDKEvent;

    const taggedEvents = $ndk.storeSubscribe(
        { kinds: [NDKKind.GroupReply, NDKKind.Reaction, NDKKind.GenericRepost], ...event.filter() },
        { subId: "tagged-events" }
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

    const replyingPubkeys = derived(replies, ($replies) => {
        const s = new Set<Hexpubkey>();
        $replies.forEach((e) => { s.add(e.pubkey); });
        return Array.from(s);
    });
</script>

<div class="grow shrink basis-0 flex-col justify-start items-end gap-1 inline-flex">
    <div class="justify-start items-start gap-3 inline-flex">
        <ReactButton {event} />

        <button class="w-7 h-7 relative" on:click={() => dispatch("comment")}>
            <ChatCircle class="w-7 h-7 text-white" weight="regular" />
        </button>

        <BoostButton {event} />
    </div>
    <div class="self-stretch text-right text-white text-opacity-60 text-sm font-normal leading-[21px]">
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
</div>