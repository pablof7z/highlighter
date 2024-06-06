<script lang="ts">
	import { NavigationOption } from './../../app';
	import TierList from "$components/Creator/TierList.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from '$utils/modal';
	import { PlusCircle } from "phosphor-svelte";
	import { Button } from '$components/ui/button';
	import NewTier from '$components/Forms/NewTier.svelte';
	import { NDKSubscriptionTier } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';

    export let forceSave = false;

    let actionButtons: NavigationOption[] = [
        { name: "Save", fn: () => { forceSave = true } }
    ]

    function showNewTier() {
        editTier = new NDKSubscriptionTier($ndk);
        tiers.push(editTier);
        tiers = tiers;
        expandedTierIndex = tiers.length - 1;
    }

    let tiers: NDKSubscriptionTier[];
    let editTier: NDKSubscriptionTier | undefined;
    let expandedTierIndex: number | undefined = undefined;

    function cont() {
        tiers = tiers;
        expandedTierIndex = undefined;
    }

    function cancelEditTier() {
        tiers.slice(expandedTierIndex);
        tiers = tiers;
        expandedTierIndex = undefined;
    }

    $: if (expandedTierIndex !== undefined) {
        actionButtons = [
            { name: "Cancel", buttonProps: {variant: 'secondary'}, fn: cancelEditTier },
            { name: "Continue", fn: cont },
        ]
    } else {
        actionButtons = [ { name: "Save", fn: () => { forceSave = true } } ]
    }
</script>

<ModalShell
    title="Support Tiers"
    class="w-full max-w-2xl flex flex-col items-stretch overflow-y-auto max-h-[70vh]"
    {actionButtons}
>
    <div>
        <TierList
            redirectOnSave={false}
            bind:forceSave
            bind:editTier
            bind:tiers
            bind:expandedTierIndex
            on:saved={closeModal}
            skipButtons
        />
    </div>

    <svelte:fragment slot="footerExtra">
        {#if expandedTierIndex === undefined}
            <Button variant={tiers?.length === 0 ? "accent" : "secondary"} on:click={showNewTier}>
                <PlusCircle class="w-6 h-6 inline mr-2" />
                New Tier
            </Button>
        {/if}

        <div class="grow"></div>
    </svelte:fragment>
</ModalShell>