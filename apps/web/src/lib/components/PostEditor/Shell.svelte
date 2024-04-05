<script lang="ts">
	import { selectedTiers, type as postType, view, nonSubscribersPreview, event, preview } from '$stores/post-editor.js';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
    import { type as _type } from "$stores/post-editor";
	import { getTierSelectionFromAllTiers } from '$lib/events/tiers';
	import { NDKArticle, NDKEvent, NDKVideo } from '@nostr-dev-kit/ndk';
	import PublishingStep from '$components/Editor/Pages/PublishingStep.svelte';
	import { onMount } from 'svelte';
	import AudiencePage from './AudiencePage.svelte';
	import { debugMode } from '$stores/session';

    export let type: "article" | "video" | "note";
    export let article: NDKArticle | undefined = undefined;
    export let video: NDKVideo | undefined = undefined;
    export let note: NDKEvent | undefined = undefined;

    console.log(type, article, video, note);

    onMount(() => {
        $view = 'edit';
        $_type = type;
    });

    $event = article ?? video ?? note!;
    console.log(`setting event`, !!$event)

    if (type === "note") {
        $preview = undefined;
    }

    $selectedTiers ??= { "Free": { name: "Free", selected: false } };
    $postType = type;

    const allTiers = getUserSubscriptionTiersStore();
    const hasTierTags = $event.tags.some(([tag]) => tag === "tier" || tag === "f");

    // $: {
        // if we already have tier tags on the main event, we are probably editing,
        // so load the tier selection from there
        $selectedTiers = getTierSelectionFromAllTiers($allTiers, hasTierTags && $event ? $event : undefined);
    // }

    // if we have tier tags on the main event, load whether we want a preview from the fact the preview event
    // has an ID or not
    if ($event.id) {
        $nonSubscribersPreview = !!$preview && !!$preview.id;
    }

    $pageHeader = { component: "post-editor" }
</script>

{#if $debugMode}
    $nonSubscribersPreview = {$nonSubscribersPreview}
    $selectedTiers = {JSON.stringify($selectedTiers)}
{/if}

<MainWrapper mobilePadded={false} class="pb-24">
    <div class="w-full" class:hidden={$view !== 'edit'}>
        <slot />
    </div>
    <div class="w-full" class:hidden={!($view === "view-preview" && $$slots.viewPreview)}>
        <slot name="viewPreview" />
    </div>
    <div class="w-full" class:hidden={!($view === "edit-preview" && $$slots.editPreview)}>
        <slot name="editPreview" />
    </div>
    <div class="w-full" class:hidden={!($view === "meta" && $$slots.meta)}>
        <slot name="meta" />
    </div>
    {#if $view === "audience"}
        <AudiencePage />
    {:else if $view === "published"}
        <PublishingStep />
    {/if}
</MainWrapper>