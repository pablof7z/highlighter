<script lang="ts">
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { ChatCircle } from 'phosphor-svelte';
	import { Readable } from "svelte/store";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import ButtonWithCount from "./ButtonWithCount.svelte";

    export let event: NDKEvent;
    export let urlPrefix: string | undefined = undefined;
    export let prefetchedReplies: Readable<NDKEvent[]> | undefined = undefined;
    export let label: string | undefined = undefined;

    let responses: NDKEventStore<NDKEvent>;

    if (!prefetchedReplies) {
        responses = $ndk.storeSubscribe(
            { kinds: [1, 12], ...event.filter() },
            {
                cacheUsage: NDKSubscriptionCacheUsage.PARALLEL,
                groupableDelay: 500,
                groupableDelayType: "at-least",
            }
        );
    }

    onDestroy(() => {
        responses?.unref();
    });

    let commentedByUser = false;

    function findUserComment(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    const replies = prefetchedReplies || responses!;

    $: commentedByUser = !!$replies.find(findUserComment);
</script>

<ButtonWithCount
    href={urlPrefix ? `${urlPrefix}/comments` : "#a"}
    count={$replies.length}
    {label}
    active={commentedByUser}
    on:click={e => { if (!urlPrefix) e.preventDefault() }}
>
    {#if !label || $replies.length === 0}
    <ChatCircle
        class="max-sm:w-6 w-5 max-sm:h-6 h-5 {commentedByUser ? 'text-accent2' : ''}}"
        weight={commentedByUser ? "fill" : "regular"}
    />
    {/if}
</ButtonWithCount>
