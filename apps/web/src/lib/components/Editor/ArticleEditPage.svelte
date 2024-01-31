<script lang="ts">
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { publishToTiers } from "$actions/publishToTiers";
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
    import truncateMarkdown from 'markdown-truncate';
	import { getUserSupportPlansStore } from "$stores/user-view";
	import CategorySelector from '../Forms/CategorySelector.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import type { UserProfileType } from '../../../app';
	import { getSelectedTiers, getTierSelectionFromAllTiers, type TierSelection } from "$lib/events/tiers";
	import ArticlePreviewEditorModal from "$modals/ArticlePreviewEditorModal.svelte";
	import { openModal } from "svelte-modals";
	import { drafts, type DraftItem, type DraftCheckpoint } from "$stores/drafts";
	import { goto } from "$app/navigation";
	import { onDestroy } from "svelte";
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import Shell from "$components/PostEditor/Shell.svelte";

    export let article: NDKArticle;
    export let preview: NDKArticle;
    export let draftItem: DraftItem | undefined = undefined;
    let draftCheckpoints: DraftCheckpoint[] = draftItem?.checkpoints ? JSON.parse(draftItem?.checkpoints) : [];

    $: article.pubkey = $user?.pubkey;

    let previewContent: string;
    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };
    let categories: string[] = [];

    let previewContentChanged = false;

    const domain = "https://highlighter.com";
    let authorLink: string = domain;
    let authorUrl: string | undefined;
    $: authorLink = authorUrl ? `${domain}${authorUrl}` : domain;
    let previewContentReadLink: string;
    $: previewContentReadLink = `\n\n--------------------------\n\nSupport my work and read the rest of this article on my Highlighter page: ${authorLink}`;

    function onArticleChange() {
        contentChangedSinceLastSave++;
        updatePreviewContent();
    }

    function updatePreviewContent() {
        if (!previewContentChanged) {
            const limit = Math.min(1500, article.content.length * 0.4);
            previewContent = truncateMarkdown(article.content, {
                limit,
                ellipsis: true
            });

            previewContent += previewContentReadLink;
        }
    }

    $: if (article.content) {
        updatePreviewContent();
    }

    let publishing = false;
    let shareUrl = "";

    let userProfile: UserProfileType;

    $: if (userProfile?.categories?.length > 0 && categories.length === 0) {
        categories = userProfile.categories;
    }

    let steps = [
        {
            title: "Write",
            description: "Write to your heart's content",
            canContinue: true,
        },
        {
            title: "Meta",
            description: "Add an image, categories, and summary",
            canContinue: true,
        },
        {
            title: "Audience",
            description: "Define this article's visibility",
            canContinue: true,
        },
        {
            title: "Publish",
            description: "Publish this article",
            canContinue: true,
        }
    ]

    let contentChangedSinceLastSave = 0;

    const saveDraftInterval = setInterval(() => {
        if (contentChangedSinceLastSave > 5) {
            saveDraft(false);
            contentChangedSinceLastSave = 0;
        }
    }, 60000);

    onDestroy(() => {
        clearInterval(saveDraftInterval);
    })

    function saveDraft(manuallySaved = true) {
        const checkpoint: DraftCheckpoint = {
            time: Date.now(),
            data: {
                article: JSON.stringify(article.rawEvent()),
                preview: JSON.stringify(preview?.rawEvent()),
                tiers,
            },
            manuallySaved
        }

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
</Shell>
