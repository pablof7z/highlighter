<script lang="ts">
	import { slide } from "svelte/transition";
	import SelectTier from "../../Forms/SelectTier.svelte";
	import Checkbox from "../../Forms/Checkbox.svelte";
	import { Info } from "phosphor-svelte";
	import { getSelectedTiers, type TierSelection } from '$lib/events/tiers';
    import { createEventDispatcher } from 'svelte';
	import { pageDrawerToggle, rightSidebar } from '@kind0/ui-common';
	import HowDoesAccessWork from '$lib/drawer/help/how-does-access-work.svelte';
	import PageTitle from "$components/Page/PageTitle.svelte";

    export let type: "article" | "video" | "note";
    export let tiers: TierSelection;
    export let nonSubscribersPreview: boolean;
    export let wideDistribution = true;
    export let canContinue: boolean;

    const dispatch = createEventDispatcher();

    let hasFree: boolean;
    $: hasFree = !!tiers["Free"]?.selected;

    let showTeaser = false;
    let howItWorks = false;

    $: if (!hasFree && !nonSubscribersPreview) {
        wideDistribution = false;
    }

    $: canContinue = getSelectedTiers(tiers).length > 0;

    function showHowItWorks() {
        $rightSidebar = {
            component: HowDoesAccessWork,
            props: {}
        }
        $pageDrawerToggle = true;
    }

    $: tiers = tiers
</script>

<div class="flex flex-col gap-10">
    <div
        class="flex flex-col lg:flex-row gap-4 lg:items-end justify-between border-b pb-4 lg:mb-4 border-base-300"
        class:lg:flex-col={howItWorks}
        class:lg:!items-start={howItWorks}
    >
        <div class="flex flex-col items-start gap-2">
            <h1 class="text-5xl text-white">
                Access & Reach
            </h1>

            <h2 class="text-neutral-500 text-xl">
                Choose which tiers can access this {type} and its reach
            </h2>
        </div>

        <div class="max-sm:w-full">
            <button
                class="bdutton text-sm flex text-white gap-2 flex-row items-center max-sm:w-full max-sm:py-2"
                on:click={showHowItWorks}
            >
                <Info class="text-lg text-info" />
                How does this work?
            </button>
        </div>
    </div>

    <SelectTier
        subtitle={`Select the tiers that will have access to this ${type}.`}
        bind:tiers
        on:changed
    />

    <div class="flex flex-col gap-4" class:hidden={tiers["Free"].selected}>
        <Checkbox bind:value={nonSubscribersPreview} button={nonSubscribersPreview}>
            <div class="text-white">
                Add a
                <span class="font-bold text-white">preview version</span>
                for
                <span class="font-bold text-white">non-subscribers</span>
            </div>
            <div slot="description" class="text-sm mt-1">
                {#if nonSubscribersPreview}
                    <div class="text-neutral-500">
                        Non-subscribers will
                        <span class="text-white">see a preview</span>
                        of this {type}.
                    </div>
                {:else}
                    <div class="text-neutral-500">
                        Non-subscribers will
                        <span class="text-white">not know</span>
                        this {type} exists.
                    </div>
                {/if}
            </div>
            <div slot="button" class="flex items-center justify-between transition-all duration-500 w-full">
                <button
                    class="button w-full"
                    on:click={() => dispatch("editPreview")} disabled={!nonSubscribersPreview}>
                    Edit Preview
                </button>
            </div>
        </Checkbox>
    </div>

    {#if hasFree || nonSubscribersPreview}
        <div transition:slide>
            <Checkbox bind:value={wideDistribution}>
                Distribute {#if !hasFree}preview version{/if} widely
                <div slot="description" class="text-sm mt-1 text-neutral-500">
                    {#if type === "article"}
                        {#if wideDistribution}
                            This {!hasFree ? "preview" : "article"} will be seen in long-form feeds beyond your Highlighter page. <br>
                            <span class="text-white">This helps you reach more readers!</span>
                        {:else}
                            This {!hasFree ? "preview" : type} will
                            <span class="text-white">only be visible on your Highlighter page</span>, not throughout other reading sites.
                        {/if}
                    {:else if type === "video"}
                        {#if wideDistribution}
                            This {!hasFree ? "preview" : "video"} will be seen in video feeds beyond your Highlighter page.
                            <br>
                            <span class="text-white">This helps you reach more viewers!</span>
                        {:else}
                            This {!hasFree ? "preview" : type} will
                            <span class="text-white">only be visible on your Highlighter page</span>, not throughout other video sites.
                        {/if}
                    {:else if type === "note"}
                        {#if wideDistribution}
                            This {!hasFree ? "preview" : "note"} will be seen in twitter-like clients beyond your Highlighter page.
                            <br>
                            <span class="text-white">This helps you reach a wider audience!</span>
                        {:else}
                            This {!hasFree ? "preview" : type} will
                            <span class="text-white">only be visible on your Highlighter page</span>, not throughout twitter-like sites.
                        {/if}
                    {/if}
                </div>
            </Checkbox>
        </div>
    {/if}
</div>
