<script lang="ts">
	import { Textarea, ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKRelay, NDKRelaySet, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { publishToTiers } from "$actions/publishToTiers";
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
    import truncateMarkdown from 'markdown-truncate';
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { getDefaultRelaySet } from '$utils/ndk';
	import CategorySelector from '../Forms/CategorySelector.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import type { UserProfileType } from '../../../app';
	import DistributionPage from "./Pages/DistributionPage.svelte";
	import ItemEditShell from "../Forms/ItemEditShell.svelte";
	import PublishingStep from "./Pages/PublishingStep.svelte";
	import { fade } from "svelte/transition";
	import { getSelectedTiers, getTierSelectionFromAllTiers, type TierSelection } from "$lib/events/tiers";

    export let article: NDKArticle;

    let step = 0;

    let previewContent: string;
    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };
    let nonSubscribersPreview = true;
    let wideDistribution = true;
    let categories: string[] = [];

    const allTiers = getUserSupportPlansStore();
    $: tiers = getTierSelectionFromAllTiers($allTiers);

    let previewContentChanged = false;

    const domain = "https://getfaaans.com";
    let authorLink: string = domain;
    let authorUrl: string | undefined;
    $: authorLink = authorUrl ? `${domain}${authorUrl}` : domain;
    let previewContentReadLink: string;
    $: previewContentReadLink = `\n\n--------------------------\n\nSupport my work and read the rest of this article on my Faaans page: ${authorLink}`;

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

    async function publish() {
        publishing = true;
        updatePreviewContent();

        const selectedTiers = getSelectedTiers(tiers);

        // Don't create a preview article if all tiers are selected
        if (selectedTiers.length === Object.values(tiers).length) {
            nonSubscribersPreview = false;
        }

        const rs = getDefaultRelaySet();
        article.relay = Array.from(rs.relays)[0];

        let previewArticle: NDKArticle | undefined;

        // Create a preview article if necessary
        if (nonSubscribersPreview) {
            previewArticle = new NDKArticle($ndk, {
                content: previewContent,
            } as NostrEvent);

            previewArticle.relay = article.relay;

            previewArticle.title = article.title;
            previewArticle.image = article.image;
            previewArticle.summary = article.summary;
        }

        // add categories
        for (const category of categories) {
            article.tags.push(["t", category]);
            if (previewArticle) previewArticle.tags.push(["t", category]);
        }

        try {
            await publishToTiers(article, tiers, {
                ndk: $ndk,
                teaserEvent: previewArticle,
                wideDistribution
            });
        } catch (e: any) {
            step--;
            publishing = false;
            newToasterMessage(e.message, "error");
            return;
        }

        const shareArticle = previewArticle ?? article;

        shareUrl = `${domain}${authorUrl}/${shareArticle.tagValue("d")}`;
        publishing = false;
    }

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
            title: "Audience",
            description: "Define this article's visibility",
            canContinue: true,
        },
        {
            title: "Categories",
            description: "Choose categories for this article",
            canContinue: true,
        },
        {
            title: "Publish",
            description: "Publish this article",
            canContinue: true,
        }
    ]

    function tiersChanged(e: CustomEvent<TierSelection>) {
        tiers = e.detail;
    }
</script>

<UserProfile user={$user} bind:userProfile bind:authorUrl />

<ItemEditShell
    bind:step
    on:publish={publish}
    bind:steps={steps}
>
    <div class="min-h-[70vh]" class:hidden={step !== 0}>
        <ArticleEditor bind:article on:contentUpdate={updatePreviewContent} textareaClass="" />
    </div>

    <div class="flex flex-col gap-10 max-sm:pt-24 max-sm:px-4" class:hidden={step !== 1}>
        <DistributionPage
            type="article"
            {tiers}
            bind:nonSubscribersPreview
            bind:wideDistribution
            bind:canContinue={steps[1].canContinue}
            on:changed={tiersChanged}
        >
            <div slot="previewEditor">
                <Textarea
                    bind:value={previewContent}
                    on:change={() => previewContentChanged = true}
                    class="w-full !bg-transparent border border-neutral-800 rounded-xl resize-none min-h-[50vh] text-lg text-white"
                />
            </div>
        </DistributionPage>
    </div>

    {#if step === 2}
        <div class="max-sm:pt-24">
            <CategorySelector bind:categories />
        </div>
    {/if}

    {#if step === 3}
        <div transition:fade={{duration: 1000}}>
            <PublishingStep
                {publishing}
                title={article.title??"Untitled"}
                {shareUrl}
            />
        </div>
    {/if}
</ItemEditShell>
