<script lang="ts">
	import { Pen } from 'phosphor-svelte';
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import SelectTier from "$components/Forms/SelectTier.svelte";
	import { makePublicAfter, nonSubscribersPreview, selectedTiers, type, view } from "$stores/post-editor";
	import MakePublicAfter from '$components/Editor/Audience/MakePublicAfter.svelte';

    function whatsPublicPreview() {

    }

    let showPublicPreview = !$selectedTiers["Free"].selected;

    $: if (!showPublicPreview && !$selectedTiers["Free"].selected) {
        showPublicPreview = true;
    } else {
        showPublicPreview = !$selectedTiers["Free"].selected;
    }

    $: if ($nonSubscribersPreview === undefined) {
        $nonSubscribersPreview = !$selectedTiers["Free"].selected;
    }


</script>

<section class="settings">
    <div class="field">
        <div class="flex flex-row justify-between">
            <div class="title">Audience</div>
            <div class="text-sm text-neutral-500">
                Choose who can access this {$type}.
            </div>
        </div>
        <SelectTier
            subtitle={`Select the tiers that will have access to this ${$type}.`}
            bind:tiers={$selectedTiers}
            alwaysOpen={true}
        />
    </div>

    <div
        class="field transition-all duration-300"
        class:opacity-0={!showPublicPreview}
        class:!hidden={!showPublicPreview}
    >
        <div class="flex flex-row justify-between">
            <div class="title">
                Public preview
            </div>

            <button class="text-sm text-neutral-500" on:click={whatsPublicPreview}>
                What's this?
            </button>
        </div>

        <div class="flex flex-col gap-4">
                <Checkbox bind:value={$nonSubscribersPreview} button={$nonSubscribersPreview} class="bg-white/5 !text-neutral-300 font-normal"
                >
                    Show a free preview to non-subscribers

                    <button
                        class="button"
                        slot="button"
                        on:click={() => $view = "edit-preview"}
                    >
                        <Pen />
                        Edit Preview
                    </button>
                </Checkbox>

                <MakePublicAfter />
        </div>

        <div class="text-sm mt-1">
            <div class="text-neutral-500">
                {#if $nonSubscribersPreview}
                    Non-subscribers will
                    <span class="text-white">see a preview</span>
                    of this {$type}.
                {:else}
                        Non-subscribers will
                        <span class="text-white">not know</span>
                        this {$type} exists.
                {/if}
                {#if $makePublicAfter}
                    The full version will be available for free
                    {#if $makePublicAfter === 1}
                        <span>1 day</span>
                    {:else if $makePublicAfter === 7}
                        <span>1 week</span>
                    {:else if $makePublicAfter === 14}
                        <span>2 weeks</span>
                    {:else if $makePublicAfter === 30}
                        <span>1 month</span>
                    {/if}
                    after publication.
                {/if}
            </div>
        </div>
    </div>
</section>
