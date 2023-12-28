<script lang="ts">
	import { Textarea } from "@kind0/ui-common";
	import { slide } from "svelte/transition";
	import SelectTier from "../SelectTier.svelte";
	import Checkbox from "../Checkbox.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { Check, Info, PlusSquare } from "phosphor-svelte";

    export let tiers: Record<string, boolean>;
    export let nonSubscribersPreview: boolean;
    export let previewContent: string;
    export let previewContentChanged: boolean;
    export let wideDistribution = true;

    let hasFree: boolean;
    $: hasFree = !!tiers["Free"];

    let showTeaser = false;
    let howItWorks = false;

    $: if (!hasFree && !nonSubscribersPreview) {
        wideDistribution = false;
    }
</script>

<div
    class="flex flex-col lg:flex-row gap-4 lg:items-end justify-between border-b pb-4 lg:mb-4 border-base-300"
    class:lg:flex-col={howItWorks}
    class:lg:items-start={howItWorks}
>
    <div class="flex flex-col items-start gap-2">
        <h1 class="text-5xl text-white">
            Access & Reach
        </h1>

        <h2 class="text-neutral-500 text-xl">
            Choose which tiers can access this article and its reach
        </h2>
    </div>

    {#if !howItWorks}
        <div class="max-sm:w-full">
            <button
                class="bdutton text-sm flex text-white gap-2 flex-row items-center max-sm:w-full max-sm:py-2"
                on:click={() => howItWorks = !howItWorks}
            >
                <Info class="text-lg text-info" />
                How does this work?
            </button>
        </div>
    {/if}

    {#if howItWorks}
        <div class="alert alert-info w-full !bg-info/20 text-white p-6 flex flex-col items-start">
            <p>Since Faaans is not a platform but rather a tool to interact with Nostr,
                your content can be seen way beyond Faaans.</p>

            <p>
                When you publish content in Nostr, you can choose how far you want your content to reach,
                which provides an organic opportunity to grow your audience without doing any additional work.
            </p>

            <p class="font-bold">
                Your work speaks for itself.
            </p>

            <button class="button px-6" on:click={() => howItWorks = !howItWorks}>
                <Check class="w-4 h-4" />
                Close
            </button>
        </div>
    {/if}
</div>

<SelectTier bind:tiers />

<div class="flex flex-col gap-4" class:hidden={tiers["Free"]}>
    <Checkbox bind:value={nonSubscribersPreview} button={nonSubscribersPreview}>
        <div class="text-white">
            Add a
            <span class="font-bold text-white">preview version</span>
            for
            <span class="font-bold text-white">non-subscribers</span>
        </div>
        <div slot="description">
            {#if nonSubscribersPreview}
                <div class="text-neutral-500">
                    Non-subscribers will
                    <span class="text-neutral-400">see a preview</span>
                    of this article.
                </div>
            {:else}
                <div class="text-neutral-500">
                    Non-subscribers will
                    <span class="text-neutral-400">not know</span>
                    this article exists.
                </div>
            {/if}
        </div>
        <div slot="button" class="flex items-center justify-between transition-all duration-500 w-full">
            <button class="button w-full" on:click={() => showTeaser = !showTeaser} disabled={!nonSubscribersPreview}>
                Edit Preview
            </button>
        </div>
    </Checkbox>

    {#if showTeaser && nonSubscribersPreview}
        <div class="transition-all duration-300" transition:slide>
            <Textarea
                bind:value={previewContent}
                on:change={() => previewContentChanged = true}
                class="w-full !bg-transparent border border-neutral-800 rounded-xl resize-none min-h-[50vh] text-lg text-white"
            />
        </div>
    {/if}
</div>

{#if hasFree || nonSubscribersPreview}
    <div transition:slide>
        <Checkbox bind:value={wideDistribution}>
            Distribute {#if !hasFree}preview version{/if} widely
            <div slot="description">
                {#if wideDistribution}
                    <div class="text-neutral-500">
                        This {!hasFree ? "preview" : "article"} will be published to long-form feeds beyond your Faaans page.
                        <br>
                        <span class="text-white">This helps you reach more readers!</span>
                    </div>
                {:else}
                    <div class="text-neutral-500">
                        This {!hasFree ? "preview" : "article"} will
                        <span class="text-white">only be visible on your Faaans page</span>, not throughout other reading sites.
                    </div>
                {/if}
            </div>
        </Checkbox>
    </div>
{/if}

<div class="md:mb-10"></div>