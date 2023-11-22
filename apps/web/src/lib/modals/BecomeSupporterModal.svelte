<script lang="ts">
	import { closeModal } from "svelte-modals";
    import TierHeader from "$components/TierHeader.svelte";
    import Tier from "$components/Tier.svelte";
	import { fade } from "svelte/transition";
	import type { NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/motion";
	import { derived } from "svelte/store";
	import { termToShort, type Term } from "$utils/term";

    export let user: NDKUser;
    export let tiers: Readable<NDKEvent[]>;

    async function onClose() {
        closeModal()
    }

    let selected: NDKEvent | undefined;
    let selectedTerm: Term = "monthly";
    let selectedAmount: string | undefined;

    const availableTerms = derived(tiers, ($tiers) => {
        const terms = new Set<Term>();
        $tiers.forEach((tier: NDKEvent) => {
            const amountTags = tier.getMatchingTags("amount")
            for (const amountTag of amountTags) {
                if (amountTag[3]) terms.add(amountTag[3] as Term);
            }
        });
        return Array.from(terms);
    });

    const sortedTiers = derived(tiers, $tiers => {
        const t = $tiers.sort((a, b) => {
            const aAmount = a.getMatchingTags("amount").find((tag) => tag[3] === selectedTerm)![1];
            const bAmount = b.getMatchingTags("amount").find((tag) => tag[3] === selectedTerm)![1];
            return Number(aAmount) - Number(bAmount);
        });

        if (!selected && t[0]) selectTier(t[0]);

        return t;
    });

    function selectTier(tier: NDKEvent) {
        selected = tier;
        selectedAmount = tier.getMatchingTags("amount").find((tag) => tag[3] === selectedTerm)![1];
    }
</script>

<div class="
    fixed
    h-screen top-0 bottom-0 left-0 px-4 lg:px-0
    flex justify-center items-center
    z-50
    w-screen
" transition:fade on:click={onClose}>
    <div class="
    card
    rounded-3xl
    shadow-xl
    flex flex-col
    relative
    overflow-y-hidden
    {$$props.class}
    " style="pointer-events: auto; max-height: 92vh;" on:click|stopPropagation={()=>{}} transition:fade>
        <div class="bg-white rounded-3xl shadow-lg px-12 pt-6 pb-10 flex-col justify-start items-center gap-6 inline-flex w-full">
            <TierHeader {user} />

            <div class="justify-center items-center inline-flex">
                {#each $availableTerms as term}
                    <button
                        class="px-2.5 py-1 rounded-full justify-center items-center flex"
                        class:bg-zinc-100={term === selectedTerm}
                        on:click={() => selectedTerm = term}
                    >
                        <div class="text-center text-black text-[15px] font-medium">{term}</div>
                    </button>
                {/each}
            </div>

            <div class="flex flex-col md:flex-row gap-4">
                {#each $sortedTiers as tier}
                    <Tier
                        {tier}
                        on:click={() => selectTier(tier)}
                        selected={selected === tier}
                        term={selectedTerm}
                    />
                {/each}
            </div>

            <div class="justify-center items-start gap-5 inline-flex">
                <button
                    class="button button-primary"
                    disabled={!selected}
                >
                    Support for ${selectedAmount}/{termToShort(selectedTerm)}
                </button>
                <button
                    class="button button-primary"
                    disabled={!selected}
                >
                    Pay in Bitcoin
                </button>
            </div>

            <button class="text-center text-black text-opacity-50 text-sm font-normal leading-5">No thanks, basic follow for free</button>
        </div>
    </div>
</div>

<style lang="postcss">
    a {
        @apply px-4 py-3 rounded-xl justify-start items-start gap-2 inline-flex;
        @apply text-black text-sm font-semibold leading-5;
        @apply flex-col justify-start items-center gap-2 inline-flex;

        & > span {
            @apply w-8 h-8 pl-1 pr-0.5 pt-0.5 pb-1 justify-center items-center inline-flex self-center;
        }

        &:hover {
            @apply hover:bg-zinc-100;
        }
    }
</style>