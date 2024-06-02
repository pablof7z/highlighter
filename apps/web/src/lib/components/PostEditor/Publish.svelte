<script lang="ts">
	import ShareModal from '$modals/ShareModal.svelte';
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
	import RadioButton from "$components/Forms/RadioButton.svelte";
    import { event, nonSubscribersPreview, previewExtraContent, status } from "$stores/post-editor";
	import { NDKArticle, NDKKind, NDKVideo } from "@nostr-dev-kit/ndk";
	import { closeModal, openModal } from '$utils/modal';
    import { prepareEventsForTierPublish, publishToTiers } from "$actions/publishToTiers";
	import { dvmScheduleEvent } from "$lib/dvm";
	import { getSelectedTiers } from "$lib/events/tiers";
	import { publishAt, makePublicAfter, preview, view, selectedTiers } from "$stores/post-editor";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { debugMode } from "$stores/session";
	import PublishValidation from "./PublishValidation.svelte";
	import { Thread } from "$utils/thread";
	import currentUser from "$stores/currentUser";
	import ThreadItem from "$components/Editor/ThreadEditor/ThreadItem.svelte";
	import { goto } from "$app/navigation";
	import { publishThread } from "$lib/utils/thread";
	import { WarningItem } from "./warnings";
	import ShareImage from "$components/Event/ShareImage.svelte";
	import ShareImageUploader from "$components/ShareImageUploader.svelte";
	import { Check } from "phosphor-svelte";
	import { getAuthorUrl, urlFromEvent } from '$utils/url';

    $: if ($event && $currentUser) {
        $event.pubkey = $currentUser?.pubkey;
        $event.author = $currentUser;
    }

    let mode: "now" | "schedule" = "now";

    let publishing = false;
    let eventPublished = false;
    let previewPublished = false;
    let makePublicScheduled = false;
    let publishAtVal: string | undefined = $publishAt?.toISOString().slice(0, -1);

    const tiers = getSelectedTiers($selectedTiers);
    if (Object.values($selectedTiers).length === tiers.length) {
        $nonSubscribersPreview = false;
    }

    $: if (publishAtVal) {
        try {
            const date = new Date(publishAtVal);
            if (date.getTime() > Date.now()) { $publishAt = date; }
        } catch(e) { console.log(e) }
    }

    async function _publishThread(thread: Thread) {
        try {
            const e = await publishThread(
                thread,
                $publishAt,
                $selectedTiers
            )
        } catch (e) {
            newToasterMessage(e.message, 'error');
        }

        if (e) goto(`/e/${e.encode()}`);
    }

    async function publish() {
        publishing = true;

        if (!$event) {
            publishing = false;
            return;
        }

        if ($event instanceof Thread) {
            return _publishThread($event);
        }

        // add preview content
        if ($preview) {
            if ($previewExtraContent?.before) {
                $preview.content = $previewExtraContent.before + `\n\n\n` + $preview.content;
            }

            if ($previewExtraContent?.after) {
                $preview.content = $preview.content + `\n\n\n` + $previewExtraContent.after;
            }
        }

        const [ eventForPublish, teaserForPublish ] = await prepareEventsForTierPublish(
            $event,
            $selectedTiers,
            {
                ndk: $ndk,
                teaserEvent: $nonSubscribersPreview ? $preview as NDKEvent : undefined,
                publishAt: $publishAt
            }
        )

        try {
            await publishToTiers(
                eventForPublish!, {
                    ndk: $ndk,
                    teaserEvent: teaserForPublish as NDKEvent,
                    publishAt: $publishAt
                }
            )
            eventPublished = true;
            if ($preview) previewPublished = true;
        } catch (e: any) {
            console.trace(e);
            newToasterMessage(e.message, "error");
            publishing = false;
            return;
        }

        if ($makePublicAfter && $preview) {
            // Publish a delete of the preview
            const publishDate = $event.created_at! + ($makePublicAfter * 24 * 60 * 60);
            const deleteEvent = await $preview.delete(`Superseded by full article ${$event.encode()}`);
            deleteEvent.created_at = publishDate;
            await deleteEvent.sign();
            await dvmScheduleEvent(deleteEvent);

            // Remove all tier mentions from event
            const tagsToRemove = ["tier", "f", "preview"]
            $event.tags = $event.tags.filter(tag => !tagsToRemove.includes(tag[0]));
            for (const tier of Object.keys($selectedTiers)) {
                $event.tags.push(["f", tier]);
            }
            $event.id = "";
            $event.created_at! += $makePublicAfter * 24 * 60 * 60;

            if ($event.sig !== "") {
                $event.sig = "";
            } else {
                $event.removeTag("published_at");
            }
            await $event.sign();
            await dvmScheduleEvent($event);
            makePublicScheduled = true;
        }

        publishing = false;

        $view = "published";
        closeModal();
        // reset("published");
    }

    let timeToPublish = 0;

    $: timeToPublish = $publishAt ? new Date($publishAt).getTime() - Date.now() : 0;

    let dateInput: HTMLInputElement;

    // Fill in preview fields if they are empty
    $: if ($preview) {
        if ($event instanceof NDKArticle && $preview instanceof NDKArticle) {
            const title = $event.title;
            const summary = $event.summary;
            const image = $event.image;

            if (title && !$preview.title) $preview.title = title;
            if (summary && !$preview.summary) $preview.summary = summary;
            if (image && !$preview.image) $preview.image = image;
        } else if ($event instanceof NDKVideo && $preview instanceof NDKVideo) {
            const title = $event.title;
            const thumbnail = $event.thumbnail;

            if (title && !$preview.title) $preview.title = title;
            if ($event.content && !$preview.content) $preview.content = $event.content;
            if (thumbnail && !$preview.thumbnail) $preview.thumbnail = thumbnail;
        }
    }

    let canPublish: boolean;

    let statusLength: number;

    $: {
        $status.length;
        setTimeout(() => statusLength = $status.length, 500);
    }

    let warnings: WarningItem[] = [];
    let progress = 0;
    let uploadStatus = 'initial';
    let url: string | undefined;
</script>

{#key statusLength}
    <PublishValidation bind:warnings bind:canPublish />
    {#key canPublish}
        {#if $event && $currentUser}
            {#if publishing}
                <h1>Publishing</h1>
            {:else}
                <button class="button" on:click={() => publishing = true}>Publish</button>
            {/if}
        
            {#if $event.kind === NDKKind.Article}
                <ShareImageUploader
                    article={$event}
                    bind:progress
                    bind:status={uploadStatus}
                    bind:url
                    addEventTagsToMedia={true}
                    publishMedia={true}
                    forceGenerate={publishing}
                    forceUpload={true}
                    on:uploaded={(e) => { console.log(e.detail) }}
                />
                {#if url}
                    Uploaded to {url}
                    <Check class="text-green-500" />
                {/if}
            {:else if $event.kind === NDKKind.HorizontalVideo}
                <div class="md:min-w-[40rem] border border-white/20 rounded-box p-3">
                    <VideoLink video={$event} skipLink={true} />
                </div>
            {:else if $event instanceof Thread}
                <div class="max-h-[50vh] overflow-y-auto discussion-wrapper w-full sm:min-w-[35rem]">
                    {#each $event.items as item, i }
                        <div class="w-full discussion-item">
                            <ThreadItem
                                item={item}
                                shouldDisplayVerticalBar={i !== $event.items.length - 1}
                                readOnly={true}
                            />

                        </div>
                    {/each}
                </div>
            {:else}
                {$event.kind}
            {/if}
        {/if}
    {/key}
{/key}
