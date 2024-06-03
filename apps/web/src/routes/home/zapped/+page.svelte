<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from '$stores/session';
	import { ndk } from "$stores/ndk.js";
	import { onDestroy } from "svelte";
    import Zap from "./Zap.svelte";
	import { layoutMode } from "$stores/layout";

    $layoutMode = "single-column-focused";

    const zaps = $ndk.storeSubscribe([
        { kinds: [NDKKind.Zap], "#P": Array.from($userFollows), limit: 2 }
    ]);

    onDestroy(() => {
        zaps.unsubscribe();
    });
</script>

<div class="flex flex-col w-full justify-stretch">
    <div class="discussion-wrapper w-full flex flex-col">
        {#each $zaps as event, i (event.id)}
            <Zap zapEvent={event} />
        {/each}
    </div>
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
