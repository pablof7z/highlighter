<script lang="ts">
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
    import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher } from "svelte";
	import { derived } from "svelte/store";

    const dispatch = createEventDispatcher();

    const mintRecommendations = $ndk.storeSubscribe({
        kinds: [18173], authors: Array.from($userFollows)
    }, { closeOnEose: true})

    const mints = $ndk.storeSubscribe({
        kinds: [38172]
    })

    const recommendationsPerMint = derived(mintRecommendations, ($mintRecommendations) => {
        const mintRecCount = new Map<string, number>();

        for (const rec of $mintRecommendations) {
            const mint = rec.tagValue("u");
            if (!mint) continue;
            mintRecCount.set(mint, (mintRecCount.get(mint) || 0) + 1);
        }

        return mintRecCount;
    })

    const sortedMints = derived([mints, mintRecommendations], ([$mints, $mintRecommendations]) => {
        const mintRecCount = new Map<string, number>();

        for (const rec of $mintRecommendations) {
            const mint = rec.tagValue("u");
            if (!mint) continue;
            mintRecCount.set(mint, (mintRecCount.get(mint) || 0) + 1);
        }

        return $mints.sort((a, b) => {
            const aUrl = a.tagValue("u");
            const bUrl = b.tagValue("u");
            if (!aUrl || !bUrl) return 0;
            const aCount = mintRecCount.get(aUrl) || 0;
            const bCount = mintRecCount.get(bUrl) || 0;
            return bCount - aCount;
        });
    })

    function click(mint: NDKEvent) {
        const url = mint.tagValue("u");
        if (!url) return;
        dispatch("click", { url, mint })
    }
</script>

{$mints.length}
<ScrollArea>
    <ul class="h-max divide-y divide-border max-h-[50vh]">
        {#each $sortedMints as mint (mint.id)}
            {#if mint.tagValue("u")}
                <li class="py-2">
                    <button on:click={() => click(mint)}>
                        {mint.tagValue("u")}

                        {#if $recommendationsPerMint.get(mint.tagValue("u"))}
                            <span class="text-accent">{$recommendationsPerMint.get(mint.tagValue("u"))}</span>
                        {/if}
                    </button>
                </li>
            {/if}
        {/each}
    </ul>
</ScrollArea>