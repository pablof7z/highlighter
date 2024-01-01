<script lang="ts">
    import { getUserSupportPlansStore, userTiers } from '$stores/user-view';
	import { ndk, newToasterMessage, user } from '@kind0/ui-common';
	import { NDKArticle, NDKEvent, NDKKind, type NostrEvent } from '@nostr-dev-kit/ndk';
	import TierEditor from './TierEditor.svelte';
	import type { Readable } from 'svelte/store';
	import { getDefaultRelaySet } from '$utils/ndk';
	import { goto } from '$app/navigation';
	import { Plus } from 'phosphor-svelte';
    import { createEventDispatcher } from 'svelte';

    export let redirectOnSave = true;

    const dispatch = createEventDispatcher();

    let tiers: NDKArticle[] = [];
    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;

    // Tracks the deleted tiers so we don't re-add them
    let deletedDtags = new Set<string>();
    $: if ($user) currentTiers = getUserSupportPlansStore();

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

    function addTier() {
        const article = new NDKArticle($ndk);
        article.kind = NDKKind.SubscriptionTier;
        tiers.push(article);
        tiers = tiers;
    }

    async function save() {
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

        dispatch("saved", { tiers: tiersList });

        if (redirectOnSave)
            goto("/dashboard");
    }
</script>

<div class="text-white text-xl font-semibold">Support Tiers</div>

{#each tiers as tier, i (i)}
    <TierEditor
        bind:tier={tier}
        on:delete={() => {
            if (tier.tagValue("d")) deletedDtags.add(tier.tagValue("d"));
            tiers = tiers.filter((_, j) => i !== j);
        }}
    />
{/each}

<div class="flex flex-row justify-between">
    <button
        class="button button-black px-6 py-3 font-semibold self-start"
        on:click={addTier}
    >
        <Plus class="w-5 h-5 mr-2" />
        Add Tier
    </button>

    <button class="button px-6" on:click={save}>
        Save
    </button>
</div>