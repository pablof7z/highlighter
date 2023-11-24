<script lang="ts">
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { X } from 'phosphor-svelte';
	import { NDKEvent, type NostrEvent } from '@nostr-dev-kit/ndk';
	import { getUserSupportPlansStore, startUserView } from '$stores/user-view';
	import { onMount } from 'svelte';
	import TierHeader from '$components/TierHeader.svelte';
	import TierEditor from '$components/TierEditor.svelte';
	import type { Term } from '$utils/term';
	import type { Readable } from 'svelte/store';
	import { goto } from '$app/navigation';

    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;

    onMount(() => {
        startUserView($user);
        currentTiers = getUserSupportPlansStore();
    })


    let tiers: Tier[] = [];
    let terms: Term[] = ["monthly"];
    const possibleTerms = ["monthly", "quarterly", "yearly"];
    let selectedTerm: Term = "monthly";
    let currency = "USD";

    function addTerm(term: string) {
        terms = [...terms, term];
    }

    function removeTerm(term: string) {
        terms = terms.filter(t => t !== term);
    }

    type Tier = {
        name: string;
        description: string;
        amounts: Record<string, string>;
        image: string;
    };

    function addTier() {
        let name = "F";
        // add the letter "A" by the the number of tiers there are
        for (let i = 0; i < tiers.length+1; i++) {
            name += "a";
        }

        name += "ns";

        tiers = [...tiers, {
            name,
            description: "Blah",
            image: "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573766/fe0d9353b56a447586507118071bb33c/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=qbzX7mOVIcgAeYnH_tHB2ARAEWIbH98YPPdjIpahYh8%3D",
            amounts: {
                monthly: "10",
                quarterly: "30",
                yearly: "100",
            },
        }];
    }

    function removeTier(tier: Tier) {
        tiers = tiers.filter(t => t !== tier);
    }

    async function saveTiers() {
        // if there are no terms, alert
        if (terms.length === 0) {
            newToasterMessage("No terms available", "error");
            return;
        }

        if (tiers.length === 0) {
            newToasterMessage("No tiers to save");
            return;
        }

        for (const tier of tiers) {
            const amountTags = terms.map(term => {
                if (tier.amounts[term]) {
                    return [ "amount", tier.amounts[term], currency, term ];
                }
            })

            const tierEvent = new NDKEvent($ndk, {
                kind: 37001,
                content: tier.description,
                tags: [
                    [ "d", tier.name ],
                    [ "title", tier.name ],
                    ...amountTags
                ]
            } as NostrEvent);

            if (tier.image) tierEvent.tags.push(["image", tier.image]);

            console.log(tierEvent.rawEvent());

            try {
                await tierEvent.publish();
                newToasterMessage("Saved", "success");
                goto("/dashboard");
            } catch (e) {
                console.error(e);
                newToasterMessage("Failed to save tiers", "error");
                return;
            }
        }
    }

    async function removeExistingTier(tier: NDKEvent) {
        await tier.delete();
        alert('remove')
    }
</script>

{#if currentTiers && $currentTiers}
<div class="flex flex-col gap-10 mx-auto max-w-prose">
    <PageTitle title="Support Tiers">
        <div class="flex flex-row gap-4">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <button on:click={addTier} class="button">Add new tier</button>
            <button on:click={saveTiers} class="button px-6" disabled={tiers.length === 0}>Save</button>
        </div>
    </PageTitle>
    <div class="mx-auto w-fit">
        <div class="px-12 pt-6 pb-10 bg-white rounded-3xl flex-col justify-start items-center gap-6 inline-flex w-full">
            <TierHeader user={$user} />
            <div class="justify-center items-center inline-flex">
                {#if terms.length === 0}
                    add at least one term
                {:else}
                    {#each terms as term}
                        <button
                            class="px-2.5 py-1 rounded-full justify-center items-center flex"
                            class:bg-zinc-100={term === selectedTerm}
                            on:click={() => selectedTerm = term}
                        >
                            <div class="text-center text-black text-[15px] font-medium">{term}</div>
                            <button class="btn btn-circle btn-ghost btn-xs ml-2" on:click={() => removeTerm(term)}>
                                <X color="black" class="text-sm" />
                            </button>
                        </button>
                    {/each}
                {/if}
                <div class="dropdown">
                    <button tabindex="0" class="button">+</button>
                    <ul tabindex="0" class="dropdown-content menu !bg-white z-50">
                        {#each possibleTerms as term}
                            {#if !terms.includes(term)}
                                <li><button class="text-black" on:click={() => addTerm(term)}>
                                    {term}
                                </button></li>
                            {/if}
                        {/each}
                    </ul>
                </div>
            </div>
            <div class="justify-start items-start gap-4 inline-flex overflow-y-auto max-w-prose">
                {#each $currentTiers as tier}
                    <TierEditor
                        {tier}
                        {terms}
                        on:remove={() => removeExistingTier(tier)}
                    />
                {/each}

                {#each tiers as tier}
                    <TierEditor
                        {terms}
                        bind:name={tier.name}
                        bind:description={tier.description}
                        bind:amounts={tier.amounts}
                        bind:image={tier.image}
                        on:remove={() => removeTier(tier)}
                    />
                {/each}
            </div>
        </div>
    </div>
</div>
{/if}