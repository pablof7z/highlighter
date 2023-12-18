<script lang="ts">
	import { ndk, user } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKRelay, NDKRelaySet, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { publishToTiers } from "$actions/publishToTiers";
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
    import truncateMarkdown from 'markdown-truncate';
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { getDefaultRelaySet } from '$utils/ndk';
	import CategorySelector from './CategorySelector.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import type { UserProfileType } from '../../../app';
	import Page2 from "./ArticleEditor/Page2.svelte";

    export let article: NDKArticle;

    let step = 0;

    let previewContent: string;
    let tiers: Record<string, boolean> = { "Free": true };
    let nonSubscribersPreview = true;
    let wideDistribution = true;
    let categories: string[] = [];

    const allTiers = getUserSupportPlansStore();

    $: for (const tier of $allTiers) {
        if (tiers[tier.title!] === undefined) {
            tiers[tier.title!] = false;
        }
    }

    let previewContentChanged = false;

    const domain = "https://getfaaans.com";
    let authorLink: string = domain;
    let authorUrl: string | undefined;
    $: authorLink = authorUrl ? `${domain}${authorUrl}` : domain;
    let previewContentReadLink: string;
    $: previewContentReadLink = `\n\n\nSupport my work and read the rest of this article on my Faaans page: ${authorLink}`;

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

    async function publish() {
        updatePreviewContent();

        // Don't create a preview article if all tiers are selected
        if (Object.keys(tiers).filter(tier => tiers[tier]).length === Object.values(tiers).length) {
            nonSubscribersPreview = false;
        }

        console.log({tiers});
        console.log(Object.keys(tiers).filter(tier => tiers[tier]).length, Object.values(tiers).length);

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

        await publishToTiers(article, tiers, {
            ndk: $ndk,
            teaserEvent: previewArticle,
            wideDistribution
        });
    }

    let userProfile: UserProfileType;

    $: if (userProfile?.categories?.length > 0 && categories.length === 0) {
        categories = userProfile.categories;

    }

    function next() {
        if (step < 2) {
            step++;
        } else {
            publish();
        }
    }
</script>

<UserProfile user={$user} bind:userProfile bind:authorUrl />

<div class="flex flex-col gap-10 sm:py-20">
    <div class="min-h-[70vh]" class:hidden={step !== 0}>
        <ArticleEditor bind:article on:contentUpdate={updatePreviewContent} textareaClass="" />
    </div>

    <div class="flex flex-col gap-10 max-sm:pt-24 max-sm:px-4" class:hidden={step !== 1}>
        <Page2
            bind:tiers
            bind:nonSubscribersPreview
            bind:previewContent
            bind:wideDistribution
            bind:previewContentChanged
        />
    </div>

    {#if step === 2}
        <div class="max-sm:pt-24">
            <CategorySelector bind:categories />
        </div>
    {/if}
</div>

<div class="
    fixed
    max-sm:top-0 sm:bottom-0
    max-sm:bg-base-200/50 sm:bg-base-200
    max-sm:backdrop-blur-sm
    w-full left-0 z-50
">
    <div class="mx-auto max-w-3xl py-3 sm:py-8 max-sm:px-4">
        <div class="flex flex-row justify-between items-center">
            <div class="flex flex-col gap-1 max-sm:hidden">
                {#if step === 0}
                    <span class="font-medium text-white/80 text-lg">
                        Write to your heart's content
                    </span>
                {/if}

                {#if step === 1}
                    <span class="font-medium text-white/80 text-lg">
                        Define this article's visibility
                    </span>
                {/if}
            </div>

            <div class="sm:hidden">
                {#if step > 0}
                    <button on:click={() => step--}>
                        Back
                    </button>
                {/if}
            </div>

            <div class="flex flex-row gap-6">
                {#if step > 0}
                    <button class="max-sm:hidden" on:click={() => step--}>
                        Back
                    </button>
                {/if}

                <button class="button" on:click={next}>
                    {#if step === 0}
                        Next: Audience
                    {:else if step === 1}
                        Next: Categories
                    {:else if step === 2}
                        Publish
                    {/if}
                </button>
            </div>
        </div>
    </div>
</div>