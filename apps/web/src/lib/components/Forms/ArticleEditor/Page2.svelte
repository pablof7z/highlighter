<script lang="ts">
	import { Textarea } from "@kind0/ui-common";
	import { slide } from "svelte/transition";
	import SelectTier from "../SelectTier.svelte";
	import Checkbox from "../Checkbox.svelte";

    export let tiers: Record<string, boolean>;
    export let nonSubscribersPreview: boolean;
    export let previewContent: string;
    export let previewContentChanged: boolean;
    export let wideDistribution = true;

    let hasFree: boolean;
    $: hasFree = !!tiers["Free"];

    let showTeaser = false;

    $: if (!hasFree && !nonSubscribersPreview) {
        wideDistribution = false;
    }
</script>

<SelectTier bind:tiers />

<div class="flex flex-col gap-4" class:hidden={tiers["Free"]}>
    <Checkbox bind:value={nonSubscribersPreview} button={nonSubscribersPreview}>
        Non-subscribers preview version
        <div slot="description">
            {#if nonSubscribersPreview}
                <div class="text-neutral-500">
                    Non-subscribers will see a preview of this article.
                </div>
            {:else}
                <div class="text-neutral-500">
                    Non-subscribers will not know this article exists.
                </div>
            {/if}
        </div>
        <div slot="button" class="flex items-center justify-between transition-all duration-500 w-full">
            <button class="button sm:text-xs w-full" on:click={() => showTeaser = !showTeaser} disabled={!nonSubscribersPreview}>
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
    <Checkbox bind:value={wideDistribution} button={wideDistribution}>
        Distribute {#if !hasFree}preview version{/if} widely
        <div slot="description">
            {#if wideDistribution}
                <div class="text-neutral-500">
                    This {!hasFree ? "preview" : "article"} will be published to long-form feeds beyond your Faaans page.
                    <br>
                    This helps you reach more readers!
                </div>
            {:else}
                <div class="text-neutral-500">
                    This {!hasFree ? "preview" : "article"} will only be visible on your Faaans page, not throughout other reading sites.
                </div>
            {/if}
        </div>
    </Checkbox>
{/if}
