<script lang="ts">
	import { newToasterMessage, user } from "@kind0/ui-common";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
    import truncateMarkdown from 'markdown-truncate';
	import UserProfile from '$components/User/UserProfile.svelte';
	import type { UserProfileType } from '../../../app';
	import { type TierSelection } from "$lib/events/tiers";
	import { drafts, type DraftItem, type DraftCheckpoint } from "$stores/drafts";
	import { goto } from "$app/navigation";
	import { onDestroy } from "svelte";
	import Shell from "$components/PostEditor/Shell.svelte";
	import ArticleMetaPage from "./ArticleMetaPage.svelte";
	import { view, preview, previewTitleChanged, previewContentChanged } from "$stores/post-editor";
	import ArticlePreviewEditor from "$components/PostEditor/ArticlePreviewEditor.svelte";

    export let article: NDKArticle;
    export let draftItem: DraftItem | undefined = undefined;
    let draftCheckpoints: DraftCheckpoint[] = draftItem?.checkpoints ? JSON.parse(draftItem?.checkpoints) : [];

    $: article.pubkey = $user?.pubkey;

    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };

    let authorUrl: string | undefined;

    function onArticleChange() {
        console.log(`content changed`);
        contentChangedSinceLastSave++;
    }

    function generatePreviewContent() {
        const limit = Math.min(1500, article.content.length * 0.4);
        return truncateMarkdown(article.content, {
            limit,
            ellipsis: true
        });
    }

    $: if ($view !== "edit-preview") {
        if ($preview instanceof NDKArticle) {
            $preview.image = article.image;
            $preview.summary = article.summary;
            $preview.tags.push(...article.getMatchingTags("t"))
            if (!$previewTitleChanged) $preview.title = article.title;
            if (!$previewContentChanged) $preview.content = generatePreviewContent()
        } else if ($preview instanceof NDKVideo) {
            $preview.thumbnail = article.image;
            if (!$previewTitleChanged) $preview.title = article.title;
            if (!$previewContentChanged) $preview.content = generatePreviewContent()
        }
    }

    let userProfile: UserProfileType;

    let contentChangedSinceLastSave = 0;

    const saveDraftInterval = setInterval(() => {
        if (contentChangedSinceLastSave > 5) {
            saveDraft(false);
            contentChangedSinceLastSave = 0;
        }
    }, 30000);

    onDestroy(() => {
        clearInterval(saveDraftInterval);
    })

    function saveDraft(manuallySaved = true) {
        const checkpoint: DraftCheckpoint = {
            time: Date.now(),
            data: {
                article: JSON.stringify(article.rawEvent()),
                preview: JSON.stringify($preview?.rawEvent()),
                tiers,
            },
            manuallySaved
        }

        console.log(`saving draft`, checkpoint);

        if (draftItem) {
            $drafts = $drafts.filter(d => d.id !== draftItem!.id);
        } else {
            draftItem = {
                type: "article",
                id: Math.random().toString(36).substring(7),
                checkpoints: "",
            }
        }

        draftCheckpoints.unshift(checkpoint);
        draftItem.checkpoints = JSON.stringify(draftCheckpoints);

        $drafts.unshift(draftItem);

        console.log(`setting drafts`, drafts)
        $drafts = $drafts

        newToasterMessage("Draft saved", "success");
        if (manuallySaved) goto("/dashboard/drafts");
    }
</script>

<UserProfile user={$user} bind:userProfile bind:authorUrl />

<Shell type="article" {article}>
    <ArticleEditor bind:article on:contentUpdate={onArticleChange} textareaClass="" />
    <div slot="meta">
        <ArticleMetaPage {article} on:done={() => $view = "edit"}/>
    </div>
    <div slot="editPreview">
        <ArticlePreviewEditor {article} {authorUrl} />
    </div>
</Shell>
