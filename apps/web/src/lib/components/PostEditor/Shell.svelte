<script lang="ts">
	import { selectedTiers, type as postType, view, nonSubscribersPreview, event, wideDistribution, preview } from '$stores/post-editor.js';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
    import { type as _type } from "$stores/post-editor";
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
        $_type = type;
    });

    $event = article ?? video ?? note!;

    if (type === "note") {
        $preview = undefined;
    }

    $selectedTiers ??= { "Free": { name: "Free", selected: false } };
    $postType = type;

    const allTiers = getUserSubscriptionTiersStore();
    $: $selectedTiers = getTierSelectionFromAllTiers($allTiers);

    $pageHeader = { component: "post-editor" }
</script>

<MainWrapper mobilePadded={false} class="pb-24">
    <div class="w-full" class:hidden={$view !== 'edit'}>
        <slot />
    </div>
    <div class="w-full" class:hidden={!($view === "edit-preview" && $$slots.editPreview)}>
        <slot name="editPreview" />
    </div>
    <div class="w-full" class:hidden={!($view === "meta" && $$slots.meta)}>
        <slot name="meta" />
    </div>
    {#if $view === "audience"}
        <AudiencePage />
    {:else if $view === "schedule"}
        <Publish {article} {note} schedule={true} />
    {:else if $view === "publish"}
        <Publish {article} {note} />
    {:else if $view === "published"}
        <PublishingStep />
    {/if}
</MainWrapper>