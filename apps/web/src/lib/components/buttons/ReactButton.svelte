<script lang="ts">
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { Heart } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";

    export let event: NDKEvent;

    const reactions = $ndk.storeSubscribe(
        { kinds: [7], ...event.filter() },
        { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY}
    );

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
</script>

<button class="w-7 h-7 relative" on:click|stopPropagation|preventDefault={react}>
    {#if reactedByUser}
        <Heart class="w-7 h-7 text-accent" weight="fill" />
    {:else}
        <Heart class="w-7 h-7 text-white" weight="regular" />
    {/if}
</button>