<script lang="ts">
    import { getUserSupportPlansStore, userTiers } from '$stores/user-view';
	import { ndk, newToasterMessage, user } from '@kind0/ui-common';
	import { NDKArticle, NDKEvent, NDKKind, type NostrEvent } from '@nostr-dev-kit/ndk';
	import TierEditor from './TierEditor.svelte';
	import type { Readable } from 'svelte/store';
	import { getDefaultRelaySet } from '$utils/ndk';
	import { goto } from '$app/navigation';
	import { Plus, Check } from 'phosphor-svelte';
    import { createEventDispatcher, onMount } from 'svelte';
	import { termToShort } from '$utils/term';
	import { currencyFormat } from '$utils/currency';

    export let redirectOnSave = true;
    export let usePresetButton = false;

    const dispatch = createEventDispatcher();

    let tiers: NDKArticle[] = [];
    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;
    let expandedTiers: number[] = [];

    // Tracks the deleted tiers so we don't re-add them
    let deletedDtags = new Set<string>();

    onMount(() => {
        currentTiers = getUserSupportPlansStore();

        if ($currentTiers && $currentTiers.length === 0) {
            addTier();
        }
    })

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
    }

    let autofocus: number;
    let canAddTier = false;

    $: canAddTier = tiers.length === 0 || !!(
        tiers[tiers.length - 1].title &&
        tiers[tiers.length - 1].getMatchingTags("amount").length
    );

    function addTier() {
        const article = new NDKArticle($ndk);
        article.kind = NDKKind.SubscriptionTier;
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

        tiers.push(article);
        expandedTiers = [tiers.length-1]
        tiers = tiers;
    }

    async function save(emit = true) {
        const relaySet = getDefaultRelaySet();
        const tiersList = new NDKEvent($ndk, {
            kind: NDKKind.TierList,
        } as NostrEvent);

        for (const tier of tiers) {
            tier.kind = NDKKind.SubscriptionTier;
            tier.created_at = Math.floor(Date.now() / 1000);
            tier.id = ""
            tier.sig = ""
            await tier.publish(relaySet);
            tiersList.tags.push(["e", tier.id]);
        }

        await tiersList.publish(relaySet);

        newToasterMessage("Support tiers correctly saved!", "success")

        if (emit) dispatch("saved", { tiers: tiersList });

        if (redirectOnSave)
            goto("/dashboard");
    }

    function skip() {
        const tier = new NDKArticle($ndk, {
            kind: NDKKind.SubscriptionTier,
            content: "Basic tier",
            tags: [
                ["perk", "Access to my members-only content"],
                ["amount", "5", "usd", "month"],
                ["perk", "Access to my members-only content"],
                ["perk", "Access to my exclusive community of like-minded people"],
            ]
        } as NostrEvent)
        tier.title = "Supporters";
        tiers.push(tier);

        save(false);

        dispatch("saved");
    }
</script>

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
                <div class="my-5">
                    <TierEditor
                        bind:tier={tier}
                        autofocus={autofocus === i}
                        on:delete={() => {
                            if (tier.tagValue("d")) deletedDtags.add(tier.tagValue("d"));
                            tiers = tiers.filter((_, j) => i !== j);
                        }}
                    />
                </div>
            {:else}
                <button
                    class="border border-base-300 p-4 flex flex-col gap-2"
                    on:click={() => {expandedTiers.push(i); expandedTiers = expandedTiers}}
                >
                    <div class="flex flex-row justify-between whitespace-nowrap truncate w-full">
                        <h1 class="text-xl font-semibold">
                            {tier.title}
                        </h1>

                        {#if tier.getMatchingTags("amount")}
                            <h2 class="text-xl font-semibold text-success">
                                {currencyFormat(
                                    tier.getMatchingTags("amount")[0][2],
                                    parseInt(tier.getMatchingTags("amount")[0][1])
                                )}/{termToShort(tier.getMatchingTags("amount")[0][3])}
                            </h2>
                        {/if}
                    </div>

                    {#if tier.content.length > 0 || tier.getMatchingTags("perk").length > 0}
                        <ul class="text-xs flex flex-col items-start gap-2">
                            {#if tier.content.length > 0}
                                <li>
                                    {tier.content}
                                </li>
                            {/if}
                            {#each tier.getMatchingTags("perk") as perkTags}
                                <li class="flex flex-row items-center">
                                    <Check class="w-5 h-5 mr-2 text-success" weight="duotone" />
                                    {perkTags[1]}
                                </li>
                            {/each}
                        </ul>
                    {/if}
                </button>
            {/if}
        {/each}
    </div>

    <div class="flex flex-row justify-between items-stretch">
        <button
            class="button button-black px-6 py-3 font-semibold"
            disabled={!canAddTier}
            on:click={addTier}
        >
            <Plus class="w-5 h-5 mr-2" />
            Add Tier
        </button>

        <div class="flex flex-row gap-4">
            {#if usePresetButton}
                <button
                    class="button button-black flex flex-col items-start gap-0 px-4"
                    on:click={skip}
                >
                    Skip
                    <span class="text-xs opacity-50">
                        Use sample tiers
                    </span>
                </button>
            {/if}

            <button class="button px-6" on:click={save}>
                {#if $$slots.saveButton}
                    <slot name="saveButton" />
                {:else}
                    Save
                {/if}
            </button>
        </div>
    </div>
</div>
