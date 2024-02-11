<script lang="ts">
	import { slide } from "svelte/transition";
	import SelectTier from "../../Forms/SelectTier.svelte";
	import Checkbox from "../../Forms/Checkbox.svelte";
	import { CaretDown, Info } from "phosphor-svelte";
	import { type TierSelection } from '$lib/events/tiers';
	import { pageDrawerToggle, rightSidebar } from '@kind0/ui-common';
	import HowDoesAccessWork from '$lib/drawer/help/how-does-access-work.svelte';
	import { makePublicAfter, nonSubscribersPreview, view, wideDistribution } from "$stores/post-editor";

    export let type: "article" | "video" | "note";
    export let tiers: TierSelection;

    let makeFreeCheck = $makePublicAfter !== undefined && Number($makePublicAfter) > 0;

    $: if (!makeFreeCheck) $makePublicAfter = false;

    function updateMakePublic() {
        if ($makePublicAfter === undefined || $makePublicAfter === false) {
            makeFreeCheck = false;
        } else {
            makeFreeCheck = true;
        }
    }

    let hasFree: boolean;
    $: {
        hasFree = !!tiers["Free"]?.selected;
    }

    $: if (!hasFree && !$nonSubscribersPreview && $wideDistribution === undefined) {
        $wideDistribution = false;
    }

    function showHowItWorks() {
        $rightSidebar = {
            component: HowDoesAccessWork,
            props: {}
        }
        $pageDrawerToggle = true;
    }

    $: tiers = tiers

    let showAdvanced = false;
</script>

<div class="flex flex-col gap-10 max-sm:px-3">
    <section class="settings">
        <div class="title">
            Audience & Reach

            <button
                class="flex gap-2 flex-row items-center max-sm:w-full max-sm:py-2 right"
                on:click={showHowItWorks}
            >
                <Info class="text-lg text-info" />
                How does this work?
            </button>
        </div>
        <div class="description">
            Choose which tiers can access this {type} and its reach
        </div>

        <div class="field">
            <div class="title">
                Content Tier
            </div>
            <SelectTier
                subtitle={`Select the tiers that will have access to this ${type}.`}
                bind:tiers
                on:changed
                class="input-background"
            />
        </div>



        <div class="field" class:!hidden={tiers["Free"].selected}>
            <Checkbox
                bind:value={makeFreeCheck}
                button={true}
                class="input-background"
                on:change={() => $makePublicAfter = 7}
            >
                Release full-version for free after
                <div slot="description" class="text-sm">
                    The full version of this {type} will be available for free after the selected time.
                </div>
                <select class="select rounded-full text-black self-center text-base bg-neutral-200 pl-4 py-0" slot="button" bind:value={$makePublicAfter} on:change={updateMakePublic}>
                    <option value={false}>never</option>
                    <option value={1}>1 day</option>
                    <option value={7}>1 week</option>
                    <option value={14}>2 weeks</option>
                    <option value={30}>1 month</option>
                </select>
            </Checkbox>
        </div>

        {#if hasFree || nonSubscribersPreview}
            <div class="field">
                <button class="text-left text-white text-sm" on:click={() => showAdvanced = !showAdvanced}>
                    Advanced
                    <CaretDown class="inline-block ml-2" />
                </button>

                {#if showAdvanced}
                    <div class="pt-4" transition:slide>
                        <div class="title">
                            Publication targets
                        </div>
                        <Checkbox bind:value={$wideDistribution} class="input-background">
                            Distribute {#if !hasFree}preview version{/if} widely
                            <div slot="description" class="text-sm mt-1 text-neutral-500">
                                {#if type === "article"}
                                    {#if $wideDistribution}
                                        This {!hasFree ? "preview" : "article"} will be seen in long-form feeds beyond your Highlighter page. <br>
                                        <span class="text-white">This helps you reach more readers!</span>
                                    {:else}
                                        This {!hasFree ? "preview" : type} will
                                        <span class="text-white">only be visible on your Highlighter page</span>, not throughout other reading sites.
                                    {/if}
                                {:else if type === "video"}
                                    {#if $wideDistribution}
                                        This {!hasFree ? "preview" : "video"} will be seen in video feeds beyond your Highlighter page.
                                        <br>
                                        <span class="text-white">This helps you reach more viewers!</span>
                                    {:else}
                                        This {!hasFree ? "preview" : type} will
                                        <span class="text-white">only be visible on your Highlighter page</span>, not throughout other video sites.
                                    {/if}
                                {:else if type === "note"}
                                    {#if $wideDistribution}
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
        {/if}
    </section>




</div>
