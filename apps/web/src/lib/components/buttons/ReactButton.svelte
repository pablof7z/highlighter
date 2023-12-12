<script lang="ts">
	import LikeIcon from "$icons/LikeIcon.svelte";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";

    export let event: NDKEvent;

    const reactions = $ndk.storeSubscribe(
        { kinds: [7], ...event.filter() },
        { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY}
    );

    onDestroy(() => {
        reactions.unref();
    });

    let reactedByUser = false;

    function findUserReaction(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    $: reactedByUser = !!$reactions.find(findUserReaction);

    async function react() {
        if (reactedByUser) {
            reactedByUser = false;
            const reaction = $reactions.find(findUserReaction);
            await reaction?.delete();
            return;
        } else {
            reactedByUser = true;

            // Give the user 5s to undo their reaction
            setTimeout(() => {
                if (reactedByUser) event.react("+1");
            }, 5000);
        }
    }
</script>

<button class="w-7 h-7 relative" on:click|stopPropagation|preventDefault={react}>
    {#if reactedByUser}
        <LikeIcon class="w-7 h-7 text-accent" />
    {:else}
        <LikeIcon class="w-7 h-7" />
    {/if}
</button>