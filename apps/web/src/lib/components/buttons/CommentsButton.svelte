<script lang="ts">
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { ChatCircle } from 'phosphor-svelte';
	import { Readable } from "svelte/store";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { pluralize } from "$utils";

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

<a
    href={urlPrefix ? `${urlPrefix}/comments` : "#"}
    class="flex flex-row items-center gap-2 {commentedByUser ? 'text-white' : ''}"
    on:click
>
    <ChatCircle
        class="w-5 h-5"
        weight={commentedByUser ? "fill" : "regular"}
    />

    {#if $replies.length > 0}
        <span class="font-light opacity-60">
            {$replies.length}
            {#if label}
                {pluralize($replies.length, label)}
            {/if}
        </span>
    {/if}
</a>