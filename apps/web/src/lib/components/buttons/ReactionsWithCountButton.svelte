<script lang="ts">
	import { ndk } from "$stores/ndk.js";
import currentUser from "$stores/currentUser.js";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from '$utils/modal';
	import { ChatCircle, Heart } from 'phosphor-svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let event: NDKEvent;

    const reactions = $ndk.storeSubscribe(
        { kinds: [7], ...event.filter() },
        {
            cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
            groupableDelayType: "at-least",
        }
    );
    let eosed = false;
    reactions.onEose(() => { eosed = true; });

    onDestroy(() => {
        reactions.unsubscribe();
    });

    let reactedByUser = false;

    function findUserReaction(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    $: reactedByUser = !!$reactions.find(findUserReaction);

    let reactionEvent: NDKEvent | undefined;

    async function react() {
        if (reactedByUser) {
            reactedByUser = false;
            const reaction = $reactions.find(findUserReaction);
            await reaction?.delete();
            reactionEvent = undefined;
            return;
        } else {
            reactedByUser = true;
            reactionEvent = await event.react("👍", false);

            // Give the user 5s to undo their reaction
            setTimeout(() => {
                if (reactionEvent) reactionEvent.publish();
            }, 5000);
        }
    }

    onDestroy(() => {
        if (reactionEvent) {
            reactionEvent.publish();
            reactionEvent = undefined;
        }
    });

    let reactionCount = 0;

    $: {
        reactionCount = $reactions.length;
        if (reactionEvent) reactionCount++;
    }
</script>

<button
    class="flex flex-row items-center gap-2 {reactedByUser ? 'text-foreground' : ''}"
    on:click|stopPropagation|preventDefault={react}
>
    <Heart
        class="w-7 h-7"
        weight={reactedByUser ? "fill" : "regular"}
    />

    {#if reactionCount > 0}
        <span class="font-light opacity-60">
            {reactionCount}
        </span>
    {/if}
</button>