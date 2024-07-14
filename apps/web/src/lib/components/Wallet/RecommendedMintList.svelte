<script lang="ts">
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";
import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
    import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { CashuMint } from "@cashu/cashu-ts";
	import { Hexpubkey, NDKEvent } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher } from "svelte";
	import { derived } from "svelte/store";
    import CashuMintListItem from "$components/Cashu/Mint/List/Item.svelte";
	import Record from "$components/buttons/Record.svelte";

    const dispatch = createEventDispatcher();

    const mintRecommendations = $ndk.storeSubscribe({
        kinds: [18173, 37375]//, authors: Array.from($userFollows)
    }, { closeOnEose: true})

    const mints = $ndk.storeSubscribe({
        kinds: [38172]
    })

    const recommendationsPerMint = derived(mintRecommendations, ($mintRecommendations) => {
        const mintRecCount = new Map<string, Set<Hexpubkey>>();

        for (const rec of $mintRecommendations) {
            let mint = rec.tagValue("u");
            mint ??= rec.tagValue("m");
            if (!mint) continue;

            const mintSet = mintRecCount.get(mint) || new Set<Hexpubkey>();
            mintSet.add(rec.pubkey);
            mintRecCount.set(mint, mintSet);
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

    const mint = new CashuMint("https://mint.agorist.space")
    mint.getInfo().then(console.log)

    let selectedMints: Record<string, boolean> = {};
</script>

<ScrollArea>
    <ul class="h-max divide-y divide-border max-h-[50vh]">
        {#each $sortedMints as mint (mint.id)}
            {#if mint.tagValue("u")}
                <CashuMintListItem url={mint.tagValue("u")} bind:checked={selectedMints[mint.tagValue("u")]}/>
            
                <!-- <li class="py-2">
                    <button class="flex flex-row justify-between w-full" on:click={() => click(mint)}>
                        {mint.tagValue("u")}

                        {#if $recommendationsPerMint.get(mint.tagValue("u"))}
                            <AvatarsPill pubkeys={Array.from($recommendationsPerMint.get(mint.tagValue("u")))}/>
                        {/if}
                    </button>
                </li> -->
            {/if}
        {/each}
    </ul>
</ScrollArea>