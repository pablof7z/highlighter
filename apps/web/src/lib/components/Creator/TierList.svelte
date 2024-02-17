<script lang="ts">
	import { ndk, user } from '@kind0/ui-common';
	import { NDKEvent, NDKKind, NDKRelay, NDKSubscriptionTier, type NostrEvent } from '@nostr-dev-kit/ndk';
	import TierEditor from './TierEditor.svelte';
	import type { Readable } from 'svelte/store';
	import { getDefaultRelaySet } from '$utils/ndk';
	import { goto } from '$app/navigation';
	import { Plus } from 'phosphor-svelte';
    import { createEventDispatcher, onMount, tick } from 'svelte';
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { inactiveUserTiers, userProfile, userTiers } from '$stores/session';
	import CollapsedTierListItem from './CollapsedTierListItem.svelte';
    import nip29 from '$lib/nip29';
	import { defaultVerifierPubkey } from '$utils/const';

    export let redirectOnSave: string | false = "/dashboard";
    export let usePresetButton = false;
    export let mobileBackUrl: string | undefined = undefined;
    export let saving = false;
    export let forceSave = false;

    const dispatch = createEventDispatcher();

    let tiers: NDKSubscriptionTier[] = [];
    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;
    let expandedTiers: number[] = [];

    // Tracks the deleted tiers so we don't re-add them
    let deletedDtags = new Set<string>();
    let autofocus: number | undefined = undefined;
    let ready = false;

    currentTiers = userTiers;

    onMount(async () => {
        if ($currentTiers && $currentTiers.length === 0) {
            const userTiers = await $ndk.fetchEvent({ kinds: [NDKKind.SubscriptionTier], authors: [$user.pubkey], limit: 1})

            if (!userTiers && $currentTiers.length === 0) {
                addTier();
            } else {
                usePresetButton = false;
            }

            ready = true;
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
        if (tiers.length > 0 && !ready) ready = true;
    }

    let canAddTier = false;

    $: canAddTier = tiers.length === 0 || !!(
        tiers[tiers.length - 1].title &&
        tiers[tiers.length - 1].getMatchingTags("amount").length
    );

    function addTier() {
        const tier = new NDKSubscriptionTier($ndk);
        autofocus = tiers.length;

        // if the last tier is expanded then remove it from the expanded tiers
        const lastIndex = tiers.length - 1;

        // if there is a last tier and it doesn't have a title or amount tags then return
        if (lastIndex >= 0 && (
            !tiers[lastIndex].title ||
            !tiers[lastIndex].getMatchingTags("amount").length
        )) return;

        if (expandedTiers.includes(lastIndex)) {
            expandedTiers = expandedTiers.filter((i) => i !== lastIndex);
        }

        tiers.push(tier);
        expandedTiers = [tiers.length-1]
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

            const name = $userProfile?.displayName || undefined;

            await nip29.createGroup($ndk, $user, name, undefined, relaySet);

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
        let tierList = await $ndk.fetchEvent({ kinds: [NDKKind.TierList], authors: [$user.pubkey] });
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
</script>

<LoadingScreen {ready}>
    <div class="flex flex-col gap-4">
        {#if tiers.length === 0}
            <div class="alert alert-neutral">
                <h1 class="text-lg py-12">
                    Create support tiers to allow your fans to support you!
                </h1>
            </div>
        {/if}

        <div class="flex flex-col">
            {#each tiers as tier, i (i)}
                {#if expandedTiers.includes(i)}
                    <TierEditor
                        bind:tier={tier}
                        autofocus={autofocus === i}
                        on:close={() => {
                            expandedTiers = expandedTiers.filter((j) => i !== j);
                        }}
                        on:delete={() => {
                            if (tier.tagValue("d")) deletedDtags.add(tier.tagValue("d"));
                            tiers = tiers.filter((_, j) => i !== j);
                        }}
                    />
                {:else}
                    <CollapsedTierListItem {tier}
                        on:click={() => {expandedTiers.push(i); expandedTiers = expandedTiers}}
                    />
                    <!-- <button class="text-red-500 text-xs" on:click={() => {
                        tier.delete();
                    }}>
                        Delete
                    </button> -->
                {/if}
            {/each}
        </div>

        <div class="flex flex-col sm:flex-row justify-between items-stretch max-sm:w-full max-sm:gap-4">
            <button
                class="button button-black px-6 py-3 font-medium max-sm:w-full"
                disabled={!canAddTier}
                on:click={addTier}
            >
                <Plus class="w-5 h-5 mr-2" />
                Add Tier
            </button>

            <div class="flex flex-col sm:flex-row gap-4 max-sm:items-stretch justify-end items-stretch max-sm:w-full">
                {#if usePresetButton}
                    <button
                        class="button button-black flex flex-col font-medium items-center gap-0 px-4 max-sm:w-full py-3"
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
            <h1>
                Inactive subscription tiers
            </h1>

            {#each $inactiveUserTiers as tier}
                <CollapsedTierListItem {tier} />
                <button on:click={() => restore(tier)}>Restore</button>
            {/each}
        {/if}
    </div>
</LoadingScreen>