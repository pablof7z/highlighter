<script lang="ts">
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
    import truncateMarkdown from 'markdown-truncate';
	import UserProfile from '$components/User/UserProfile.svelte';
	import type { UserProfileType } from '../../../app';
	import { type DraftItem } from "$stores/drafts";
	import Shell from "$components/PostEditor/Shell.svelte";
	import { view, preview, previewTitleChanged, previewContentChanged, currentDraftItem } from "$stores/post-editor";
	import ArticlePreviewEditor from "$components/PostEditor/ArticlePreviewEditor.svelte";
	import ArticleView from "$components/ArticleView.svelte";
	import { debugMode } from "$stores/session";
	import currentUser from "$stores/currentUser";
	import { pageHeader } from "$stores/layout";

    export let article: NDKArticle;
    export let draftItem: DraftItem | undefined = undefined;

    $: $currentDraftItem = draftItem;

    $: article.pubkey = $currentUser?.pubkey;

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

    let currentView: string;
    let signedAt: number = 0;

    $: if (currentView !== $view) {
        if ($view === "view-preview") {
            article.sign().then(() => {
                currentView = $view;
                signedAt = Date.now();
            });
        } else {
            currentView = $view;
        }
    }

    $: if ($pageHeader?.props) {
        switch ($view) {
            case 'edit':
                $pageHeader.props.showPublish = true;
                $pageHeader.props.showPreview = true;
                $pageHeader.props.showSaveDraft = true;
                $pageHeader.props.showAudience = true;
                break;
            case 'view-preview':
                $pageHeader.props.shoEdit = true;
                $pageHeader.props.showPublish = true;
                break;
        }
    }
</script>

<UserProfile user={$currentUser} bind:userProfile bind:authorUrl />

<Shell type="article" {article}>
    <ArticleEditor bind:article on:contentUpdate={onArticleChange} />
    <div slot="viewPreview">
        {#if $view === "view-preview"}
            {#key signedAt}
                <ArticleView bind:article isFullVersion={true} isPreview={true} fillInSummary={false} />
            {/key}
        {/if}
    </div>
    <div slot="editPreview">
        <ArticlePreviewEditor {article} {authorUrl} />
    </div>
</Shell>

