<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKRelay, NDKSubscriptionCacheUsage, NDKSubscriptionTier, type NostrEvent } from '@nostr-dev-kit/ndk';
	import TierEditor from './TierEditor.svelte';
	import type { Readable } from 'svelte/store';
	import { getDefaultRelaySet } from '$utils/ndk';
	import { goto } from '$app/navigation';
	import { CaretDown, CaretUp, Plus, Trash } from 'phosphor-svelte';
    import { createEventDispatcher, onMount, tick } from 'svelte';
	import { inactiveUserTiers, userProfile, userTiers } from '$stores/session';
	import CollapsedTierListItem from './CollapsedTierListItem.svelte';
    import nip29 from '$lib/nip29';
	import { defaultVerifierPubkey } from '$utils/const';
	import currentUser from '$stores/currentUser';

    export let redirectOnSave: string | false = "/dashboard";
    export let usePresetButton = false;
    export let skipButtons = false;
    export let saving = false;
    export let forceSave = false;
    export let editTier: NDKSubscriptionTier | undefined = undefined;

    const dispatch = createEventDispatcher();

    export let tiers: NDKSubscriptionTier[] = [];
    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;
    export let expandedTierIndex: number | undefined = undefined;

    // Tracks the deleted tiers so we don't re-add them
    let deletedDtags = new Set<string>();
    let autofocus: number | undefined = undefined;

    currentTiers = userTiers;

    onMount(async () => {
        if ($currentUser && $currentTiers && $currentTiers.length === 0) {
            // const userTiers = await $ndk.fetchEvent({ kinds: [NDKKind.SubscriptionTier], authors: [$currentUser.pubkey], limit: 1})

            // if (!userTiers && $currentTiers.length === 0) {
            // } else {
            //     usePresetButton = false;
            // }
        }
    })

    $: if (forceSave && !saving) {
        save();
    }

    $: if ($currentTiers) {
        for (const tierEvent of $currentTiers) {
            const dTag = tierEvent.tagValue("d");
            const existingTier = tiers.find(t => t.tagValue("d") === dTag);
            if (
                existingTier ||
                deletedDtags.has(dTag)
            ) continue;

            tiers.push(tierEvent);
        }

        tiers = tiers;
        tick();
    }

    let canAddTier = false;

    $: canAddTier = tiers.length === 0 || !!(
        tiers[tiers.length - 1].title &&
        tiers[tiers.length - 1].getMatchingTags("amount").length
    );

    function addTier() {
        editTier = new NDKSubscriptionTier($ndk);
        autofocus = tiers.length;

        // if the last tier is expanded then remove it from the expanded tiers
        const lastIndex = tiers.length - 1;

        // if there is a last tier and it doesn't have a title or amount tags then return
        if (lastIndex >= 0 && (
            !tiers[lastIndex].title ||
            !tiers[lastIndex].getMatchingTags("amount").length
        )) return;

        tiers.push(editTier);
        expandedTierIndex = tiers.length-1;
        tiers = tiers;
    }

    async function save(emit = true) {
        saving = true;
        try {
            const relaySet = getDefaultRelaySet();
            const tiersList = new NDKEvent($ndk, {
                kind: NDKKind.TierList,
            } as NostrEvent);

            const promises: Promise<Set<NDKRelay>>[] = [];

            for (const tier of tiers) {
                tier.kind = NDKKind.SubscriptionTier;
                tier.created_at = Math.floor(Date.now() / 1000);
                tier.id = ""
                tier.sig = ""

                // Add the creator relays to the tier
                tier.removeTag("r");
                tier.removeTag("p");
                tier.removeTag("client");
                tier.verifierPubkey = defaultVerifierPubkey;
                for (const relay of relaySet.relays) { tier.tags.push(["r", relay.url]); }

                await tier.sign();
                promises.push(tier.publish());
                tiersList.tags.push(["e", tier.id]);
            }

            await Promise.all([
                tiersList.publish(),
                ...promises
            ]);

            const name = $currentUser?.displayName || undefined;

            await nip29.createGroup($ndk, $currentUser, name, undefined, relaySet);

            if (emit) dispatch("saved", { tiers: tiersList });

            if (redirectOnSave)
                goto(redirectOnSave);
        } finally {
            saving = false;
        }
    }

    function skip() {
        const tier = new NDKSubscriptionTier($ndk, {
            kind: NDKKind.SubscriptionTier,
            content: "Basic tier",
        } as NostrEvent)
        tier.addPerk("Access to my members-only content");
        tier.addPerk("Access to my exclusive community of like-minded people");
        tier.addAmount(500, "USD", "monthly");
        tier.addAmount(100000, "msat", "monthly");
        tier.title = "Supporters";
        tiers.push(tier);

        save(false);

        dispatch("saved");
    }

    async function restore(tier: NDKSubscriptionTier) {
        let tierList = await $ndk.fetchEvent({ kinds: [NDKKind.TierList], authors: [$currentUser.pubkey] });
        if (!tierList) {
            tierList = new NDKEvent($ndk, {
                kind: NDKKind.TierList,
            } as NostrEvent);
        } else {
            tierList.id = ""; tierList.sig = "";
        }

        tierList.tags.push(["e", tier.id]);
        await tierList.publish();
    }

    let showInactive = false;

    function moveUp(i: number) {
        if (i === 0) return;
        const temp = tiers[i];
        tiers[i] = tiers[i - 1];
        tiers[i - 1] = temp;
        tiers = tiers;
    }

    function moveDown(i: number) {
        if (i === tiers.length - 1) return;
        const temp = tiers[i];
        tiers[i] = tiers[i + 1];
        tiers[i + 1] = temp;
        tiers = tiers;
    }

    function deleteTier(tier: NDKSubscriptionTier) {
        if (tier.dTag) deletedDtags.add(tier.dTag);
        tiers = tiers.filter((t) => t !== tier);
    }
</script>

<div class="flex flex-col gap-4 items-stretch w-full">
    {#if tiers.length === 0}
        <div class="alert alert-neutral">
            <h1 class="text-lg py-12">
                Create support tiers to allow your fans to support you!
            </h1>
        </div>
    {/if}

    <ul class="flex flex-col w-full gap-4">
        {#if expandedTierIndex !== undefined}
            <TierEditor
                bind:tier={tiers[expandedTierIndex]}
                autofocus={true}
                on:close={() => {
                    expandedTierIndex = undefined;
                }}
                on:delete={() => {
                    if (tiers[expandedTierIndex]?.dTag) deletedDtags.add(tiers[expandedTierIndex].dTag);
                    tiers = tiers.filter((_, j) => expandedTierIndex !== j);
                    expandedTierIndex = undefined;
                }}
            />
        {:else}
            {#each tiers as tier, i (i)}
                <div class="w-full group flex flex-row items-stretch">
                    <CollapsedTierListItem {tier}
                        on:click={() => {expandedTierIndex = i}}
                    />
                    <div class="flex flex-col items-center gpa-2 transition-all duration-300 self-stretch opacity-10 group-hover:opacity-100 w-8">
                        <button class="" on:click={() => {moveUp(i)}} disabled={i === 0}>
                            <CaretUp class="w-5 h-5" />
                        </button>

                        <button class="" on:click={() => moveDown(i)} disabled={i === tiers.length - 1}>
                            <CaretDown class="w-5 h-5" />
                        </button>

                        <button class="text-red-500 mt-2" on:click={() => deleteTier(tier)}>
                            <Trash class="w-5 h-5" />
                        </button>
                    </div>
                </div>
            {/each}
        {/if}
    </ul>

    <div
        class="flex flex-col sm:flex-row justify-between items-stretch max-sm:w-full max-sm:gap-4 mr-8"
        class:hidden={
            expandedTierIndex !== undefined ||
            skipButtons
        }
    >
        <button
            class="button-black max-sm:w-full"
            disabled={!canAddTier}
            on:click={addTier}
        >
            <Plus class="w-5 h-5 mr-2" />
            Add Tier
        </button>

        <div class="flex flex-col sm:flex-row gap-4 max-sm:items-stretch justify-end items-stretch max-sm:w-full">
            {#if usePresetButton}
                <button
                    class="button-black flex flex-col font-medium items-center gap-0 px-4 max-sm:w-full py-3"
                    on:click={skip}
                >
                    Skip using sample tiers for now
                </button>
            {/if}

            <button class="button px-6" disabled={saving} on:click={() => save()}>
                {#if saving}
                    <div class="loading loading-sm"></div>
                {:else if $$slots.saveButton}
                    <slot name="saveButton" />
                {:else}
                    Save
                {/if}
            </button>
        </div>
    </div>

    {#if $inactiveUserTiers.length > 0}
        <div class="divider"></div>

        <button class="self-start button" on:click={() => showInactive = !showInactive}>
            Inactive subscription tiers
        </button>

        {#if showInactive}
            {#each $inactiveUserTiers as tier}
                <CollapsedTierListItem {tier} />
                <button class="self-end button-black" on:click={() => restore(tier)}>Restore</button>
            {/each}
        {/if}
    {/if}
</div>