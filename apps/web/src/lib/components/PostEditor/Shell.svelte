<script lang="ts">
	import { selectedTiers, type as postType, view, nonSubscribersPreview, event, wideDistribution } from '$stores/post-editor.js';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
	import { getTierSelectionFromAllTiers } from '$lib/events/tiers';
	import { NDKArticle, NDKEvent, NDKVideo } from '@nostr-dev-kit/ndk';
	import Publish from './Publish.svelte';
	import PublishingStep from '$components/Editor/Pages/PublishingStep.svelte';
	import { onMount } from 'svelte';
	import AudiencePage from './AudiencePage.svelte';

    export let type: "article" | "video" | "note";
    export let article: NDKArticle | undefined = undefined;
    export let video: NDKVideo | undefined = undefined;
    export let note: NDKEvent | undefined = undefined;

    onMount(() => {
        $view = 'edit';
    });

    $event = article ?? video ?? note;

    $selectedTiers ??= { "Free": { name: "Free", selected: false } };
    $postType = type;

    const allTiers = getUserSubscriptionTiersStore();
    $: $selectedTiers = getTierSelectionFromAllTiers($allTiers);

    $pageHeader = { component: "post-editor" }

    function tiersChanged() {
        if ($nonSubscribersPreview === undefined) {
            console.log("nonSubscribersPreview is undefined, setting to true", $selectedTiers["Free"]?.selected);
            if (!$selectedTiers["Free"]?.selected) {
                console.log("Free is not selected, setting to true", $postType);
                if ($postType === "article") $nonSubscribersPreview = true;
            }
        }
    }
</script>

<MainWrapper mobilePadded={false} class="pb-24">
    {#if $view === 'edit'}
        <slot />
    {:else if $view === "edit-preview" && $$slots.editPreview}
        <slot name="editPreview" />
    {:else if $view === "meta" && $$slots.meta}
        <slot name="meta" />
    {:else if $view === "audience"}
        <AudiencePage />
    {:else if $view === "schedule"}
        <Publish {article} {note} schedule={true} />
    {:else if $view === "publish"}
        <Publish {article} {note} />
    {:else if $view === "published"}
        <PublishingStep />
    {/if}
</MainWrapper>