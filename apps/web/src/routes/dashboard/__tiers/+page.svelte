<script lang="ts">
	import PageTitle from "$components/Page/PageTitle.svelte";
    import TierEditorEmpty from "$components/TierEditorEmpty.svelte";
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
    import TierHeader from "$components/TierHeader.svelte";
	import NDK, { NDKEvent, NDKKind, type NDKEventId, type NostrEvent } from '@nostr-dev-kit/ndk';
	import { getUserSupportPlansStore, startUserView, userSubscription } from '$stores/user-view';
	import { onDestroy, onMount } from 'svelte';
    import Terms from "./Terms.svelte";
	import TierEditor from '$components/TierEditor.svelte';
    import type { Term } from '$utils/term';
	import type { Readable } from 'svelte/store';
	import { goto } from '$app/navigation';
	import { amountsFromTier, amountTag, type Tier } from "./tier";
	import { getDefaultRelaySet } from "$utils/ndk";

    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;
    // let currentTiersModified: Record<NDKEventId, boolean> = {};
    // let currentTierDetails: Record<NDKEventId, Tier> = {};

    let tiers: Tier[] = [];

    onMount(() => {
        startUserView($user);
        currentTiers = getUserSupportPlansStore();
    })

    onDestroy(() => {
        userSubscription?.unref();
    })

    $: if ($currentTiers) {
        for (const tierEvent of $currentTiers) {
            // check if we already have this tier and replace or push
            const dTag = tierEvent.tagValue("d");
            const existingTier = tiers.find(t => t.dTag === dTag);
            if (existingTier) continue;

            const tier = {
                localId: dTag,
                dTag,
                name: tierEvent.tagValue("title"),
                description: tierEvent.content,
                image: tierEvent.tagValue("image"),
                amounts: amountsFromTier(tierEvent),
                modified: false
            };

            for (const amountTag of tierEvent.getMatchingTags("amount")) {
                if (amountTag && amountTag[2]) {
                    if (!changedCurrency)
                        currency = amountTag[2];
                }

                if (amountTag && amountTag[3]) {
                    if (!terms?.includes(amountTag[3])) {
                        terms = [...(terms??[]), amountTag[3]];
                        console.log(terms);
                    }
                }
            }

            tiers.push(tier);
        }

        if (!terms || terms.length === 0) {
            terms = ["monthly"];
        }

        tiers = tiers;
    }

    let terms: Term[] | undefined;
    let currency: string | undefined = "USD";
    let changedCurrency: boolean = false;

    function addTier() {
        let name = "F";
        // add the letter "A" by the the number of tiers there are
        for (let i = 0; i < Object.values(tiers).length+1; i++) {
            name += "a";
        }

        name += "ns";

        const rand = Math.floor(Math.random() * 1000000).toString();

        const tier = {
            localId: rand,
            name,
            description: "",
            image: "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573766/fe0d9353b56a447586507118071bb33c/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=qbzX7mOVIcgAeYnH_tHB2ARAEWIbH98YPPdjIpahYh8%3D",
            amounts: {
                monthly: "10",
                quarterly: "30",
                yearly: "100",
            },
        };

        tiers.push(tier);
        tiers = tiers;
    }

    function removeTier(tier: Tier) {
        for (const t of tiers) {
            if (t === tier) {
                t.deleted = true;
                break;
            }
        }

        tiers = tiers;
    }

    async function saveTiers() {
        // if there are no terms, alert
        if (terms.length === 0) {
            newToasterMessage("No terms available", "error");
            return;
        }

        const tiersList = new NDKEvent($ndk, {
            kind: NDKKind.TierList,
        } as NostrEvent);

        for (const tier of tiers) {
            if (tier.modified === false && tier.deleted === false) continue;

            if (tier.deleted) {
                const tierEvent = $currentTiers?.find(t => t.tagValue("d") === tier.dTag);
                if (tierEvent) {
                    await tierEvent.delete();
                    newToasterMessage("Deleted", "success");
                } else {
                    newToasterMessage("Failed to delete tier", "error");
                    console.error(`Failed to delete tier ${tier.dTag}`);
                }

                continue;
            }

            const amountTags = terms.map(term => {
                if (tier.amounts[term]) {
                    return amountTag(tier.amounts[term], currency, term);
                }
            })

            const tierEvent = new NDKEvent($ndk, {
                kind: NDKKind.SubscriptionTier,
                content: tier.description,
                tags: [
                    [ "title", tier.name ],
                    ...amountTags
                ]
            } as NostrEvent);

            if (tier.image) tierEvent.tags.push(["image", tier.image]);

            try {
                await tierEvent.sign();
                console.log(`tier to publish`, tierEvent.rawEvent())
                await tierEvent.publish();
                tiersList.tags.push(["e", tierEvent.id]);
                newToasterMessage("Saved", "success");
                goto("/dashboard");
            } catch (e) {
                console.error(e);
                newToasterMessage("Failed to save tiers", "error");
                return;
            }
        }

        console.log(tiersList.rawEvent());
        await tiersList.sign();
        console.log(tiersList.rawEvent());
        await tiersList.publish(getDefaultRelaySet());
    }

    let modifiedTiers = 0;

    $: {
        const someModifiedTier = Object.values(tiers).filter(t => t.modified);
        const someTierToDelete = Object.values(tiers).filter(t => t.deleted);
        const someNewTier = Object.values(tiers).filter(t => !t.dTag);
        modifiedTiers = someModifiedTier.length + someTierToDelete.length + someNewTier.length;
    }
</script>

{#if currentTiers && $currentTiers}
<div class="flex flex-col gap-10 mx-auto max-w-5xl">
    <PageTitle title="Support Tiers">
        <div class="flex flex-row gap-4">
            <button on:click={addTier} class="button">Add new tier</button>
            <button on:click={saveTiers} class="button px-6">
                Save
            </button>
        </div>
    </PageTitle>
    <div class="mx-auto w-fit">
        <div class="px-12 pt-6 pb-10 bg-white rounded-3xl flex-col justify-start items-center gap-6 inline-flex w-full">
            <TierHeader user={$user} />
            <div class="justify-center items-center inline-flex gap-4">

                <select
                    value={currency}
                    class="bg-zinc-100 border-none rounded-lg text-black text-sm font-medium"
                    on:change={e => {
                        currency = e.target.value;
                    }}
                >
                    <option value="USD">USD</option>
                    <option value="EUR">EUR</option>
                    <option value="msat">Bitcoin</option>
                </select>

                <Terms
                    terms={terms??["monthly"]}
                    on:change={(e) => terms = e.detail}
                />
            </div>
            <div class="justify-start items-start gap-4 inline-flex overflow-y-auto max-w-3xl">
                {#if tiers.filter(t => !t.deleted).length === 0}
                    <TierEditorEmpty on:click={addTier} />
                {/if}

                {#each tiers as tier, i}
                    {#if !tier.deleted}
                        <TierEditor
                            currency={currency||"USD"}
                            {terms}
                            bind:tier={tiers[i]}
                            event={$currentTiers.find(t => t.tagValue("d") === tier.dTag)}
                            on:save={() => saveTiers()}
                            on:remove={() => removeTier(tier)}
                        />
                    {/if}
                {/each}

            </div>

            {#if tiers.filter(t => !t.deleted).length > 0}
                <button on:click={addTier} class="button">Add new tier</button>
            {/if}
        </div>
    </div>
</div>
{/if}