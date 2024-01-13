<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { openModal } from 'svelte-modals';
	import { getContent, getUserSupportPlansStore } from "$stores/user-view";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import type { Readable } from "svelte/store";

    export let allDone = false;
    export let type: "horizontal" | "vertical" = "vertical";

    let currentTiers: Readable<NDKEvent[]> | undefined = undefined;
    let content: Readable<NDKEvent[]> | undefined = undefined;

    let hasTiers = false;
    let hasContent = false;
    let hasProfileBanner  = true;

    onMount(() => {
        currentTiers = getUserSupportPlansStore();
        content = getContent();
    })

    $: hasTiers = !!currentTiers && !!$currentTiers?.length;
    $: hasContent = !!content && !!$content?.length;

    $: allDone = hasTiers && hasContent && hasProfileBanner;

    function createContent() {
        openModal(NewItemModal);
    }
</script>

<ul class="steps steps-{type}">
    <li class="step done" data-content="✓">Register</li>
    <li
        class="step"
        class:done={hasTiers}
        data-content={hasTiers ? "✓" : ""}
    >Create Support Tiers</li>
    {#if hasContent}
        <li class="step done" data-content="✓"><button on:click={createContent}>Publish</button></li>
    {:else}
        <li class="step"><button on:click={createContent}>Publish</button></li>
    {/if}
</ul>

<style lang="postcss">
    .done {
        @apply step-accent;
    }
</style>