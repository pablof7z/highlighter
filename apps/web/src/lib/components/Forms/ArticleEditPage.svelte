<script lang="ts">
	import PublishButton from '$components/buttons/PublishButton.svelte';
	import PageTitle from "$components/Page/PageTitle.svelte";
    import Input from "$components/Forms/Input.svelte";
	import { Textarea, ndk, newToasterMessage, user } from "@kind0/ui-common";
	import SelectTier from "$components/Forms/SelectTier.svelte";
	import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKRelaySet, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { defaultRelays, publishToTiers } from "$actions/publishToTiers";
	import { slide } from "svelte/transition";
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
    import truncateMarkdown from 'markdown-truncate';
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { page } from '$app/stores';

    export let article: NDKArticle;

    let previewContent: string;
    let tiers: Record<string, boolean> = { "Free": false };
    let nonSubscribersPreview = true;

    const allTiers = getUserSupportPlansStore();

    let publishingAllowed = false;
    let publishButtonTooltip = "Initializing";

    $: for (const tier of $allTiers) {
        if (tiers[tier.title] === undefined) {
            tiers[tier.title] = false;
        }
    }

    $: {
        const someTierSelected = Object.keys(tiers).filter(tier => tiers[tier]).length > 0;
        publishingAllowed = false;

        if (!someTierSelected) {
            publishButtonTooltip = "Select at least one tier";
        } else if (!article.content) {
            publishButtonTooltip = "Add some content";
        } else if (!article.title) {
            publishButtonTooltip = "Add a title";
        } else {
            publishButtonTooltip = "Publish";
            publishingAllowed = true;
        }
    }

    let publishing = false;
    let previewContentChanged = false;

    let showTeaser = false;

    function updatePreviewContent() {
        if (!previewContentChanged) {
            const limit = Math.min(1500, article.content.length * 0.4);
            previewContent = truncateMarkdown(article.content, {
                limit,
                ellipsis: true
            });
        }
    }

    $: if (article.content) {
        updatePreviewContent();
    }

    async function publish() {
        updatePreviewContent();

        const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);

        article.relay = Array.from(relaySet.relays)[0];

        let previewArticle: NDKArticle | undefined;

        // Don't create a preview article if all tiers are selected
        if (Object.keys(tiers).filter(tier => tiers[tier]).length === Object.values(tiers).length) {
            nonSubscribersPreview = false;
        }

        // Create a preview article if necessary
        if (nonSubscribersPreview) {
            previewArticle = new NDKArticle($ndk, {
                content: previewContent,
            } as NostrEvent);
            previewArticle.relay = Array.from(relaySet.relays)[0];
            previewArticle.title = article.title;
            previewArticle.image = article.image;
            previewArticle.summary = article.summary;
        }

        await publishToTiers(article, tiers, {
            relaySet,
            ndk: $ndk,
            teaserEvent: previewArticle
        });
    }

    function preview() {
    }
</script>

<div class="flex flex-col gap-10">
    <PageTitle title="New Article">
        <div class="flex flex-row gap-2">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <div class="tooltip" data-tip={publishButtonTooltip}>
                <button on:click={publish} class="button px-10" disabled={!publishingAllowed}>Publish</button>
            </div>
        </div>
    </PageTitle>

    <ArticleEditor bind:article on:contentUpdate={updatePreviewContent} />

    <SelectTier bind:tiers />

    <div class="flex flex-col gap-4" class:hidden={tiers["Free"]}>
        <label class="text-white text-base font-medium flex flex-row gap-2 items-cente justify-between">
            <div class="flex flex-row items-start">
                <input type="checkbox" class="checkbox mr-2" bind:checked={nonSubscribersPreview} />
                <div class="flex flex-col items-start">
                    Non-subscribers Teaser
                    <div class="text-neutral-500 text-sm">Allow non-subscribers to preview this article</div>
                </div>
            </div>

            <div class="flex items-center justify-between transition-all duration-500" class:opacity-0={!nonSubscribersPreview}>
                <button class="button text-xs" on:click={() => showTeaser = !showTeaser} disabled={!nonSubscribersPreview}>
                    Edit Teaser
                </button>
            </div>
        </label>

        {#if showTeaser}
            <div class="transition-all duration-300" transition:slide>
                <Textarea
                    bind:value={previewContent}
                    on:change={() => previewContentChanged = true}
                    class="w-full !bg-transparent border border-neutral-800 rounded-xl resize-none min-h-[50vh] text-lg text-white"
                />
            </div>
        {/if}
    </div>
</div>