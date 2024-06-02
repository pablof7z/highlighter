<script lang="ts">
	import { selectedTiers, type as postType, view, nonSubscribersPreview, event, preview, currentDraftItem } from '$stores/post-editor.js';
	import { pageHeader, resetLayout } from "$stores/layout";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
    import { type as _type } from "$stores/post-editor";
	import { getTierSelectionFromAllTiers } from '$lib/events/tiers';
	import { NDKArticle, NDKEvent, NDKVideo } from '@nostr-dev-kit/ndk';
	import PublishingStep from '$components/Editor/Pages/PublishingStep.svelte';
	import { onDestroy, onMount } from 'svelte';
	import AudiencePage from './AudiencePage.svelte';
	import Toolbar from './Toolbar.svelte';
	import { goto } from '$app/navigation';
	import { ArticleCheckpoint } from '$stores/drafts';
	import { Thread } from '$utils/thread';
	import { newToasterMessage } from '@kind0/ui-common';
	import { addDraftCheckpoint } from '$utils/drafts';
	import { appMobileHideNewPostButton } from '$stores/app';
	import Publish from './Publish.svelte';

    export let type: "article" | "video" | "thread";
    export let article: NDKArticle | undefined = undefined;
    export let video: NDKVideo | undefined = undefined;
    export let note: NDKEvent | undefined = undefined;

    export let onSaveDraft: ((manuallySaved: boolean) => void) | undefined = undefined;

    /**
     * Whether the shell should create an interval to auto-save drafts
     */
    export let timedDraftSave = true;

    $appMobileHideNewPostButton = true;

    onMount(() => {
        $view = 'publish';
        $_type = type;
        $event.title = "hi";
        $event.summary = 'here';
        $event.content = "hello"
    });

    $event = article ?? video ?? note!;

    $selectedTiers ??= { "Free": { name: "Free", selected: false } };
    $postType = type;

    const allTiers = getUserSubscriptionTiersStore();
    const hasTierTags = $event?.tags.some(([tag]) => tag === "tier" || tag === "f");

    // $: {
        // if we already have tier tags on the main event, we are probably editing,
        // so load the tier selection from there
        $selectedTiers = getTierSelectionFromAllTiers($allTiers, hasTierTags && $event ? $event : undefined);
    // }

    // if we have tier tags on the main event, load whether we want a preview from the fact the preview event
    // has an ID or not
    if ($event?.id) {
        $nonSubscribersPreview = !!$preview && !!$preview.id;
    }

    $pageHeader = {
        component: Toolbar,
        props: {
            onSaveDraft: saveDraft,
            onPublish: publish,
        }
    }

    function publish() {
        $view = "published";
    }

    function saveDraft(manuallySaved = true) {
        if (onSaveDraft) {
            onSaveDraft(manuallySaved);
        } else if ($event && !($event instanceof Thread)) {
            const data: ArticleCheckpoint = {
                event: JSON.stringify($event.rawEvent()),
                preview: "",
            };

            if ($preview) { data.preview = JSON.stringify($preview.rawEvent()); }
            
            const item = addDraftCheckpoint(
                manuallySaved,
                $currentDraftItem,
                data,
                $_type!
            );

            if (item) {
                $currentDraftItem = item;
            }
        }

        newToasterMessage("Draft saved", "success");

        if (manuallySaved && $currentDraftItem) {
            goto(`/drafts/${$currentDraftItem.id}`);
        }
    }

    let draftSaveInterval: any;

    if (timedDraftSave) {
        draftSaveInterval = setInterval(() => {
            saveDraft(false);
        }, 30000);
    }

    onDestroy(() => {
        resetLayout();
        
        if (draftSaveInterval) {
            clearInterval(draftSaveInterval);
        }
    })
</script>

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
{:else if $view === "publish"}
    <Publish />
{:else if $view === "published"}
    <PublishingStep />
{/if}