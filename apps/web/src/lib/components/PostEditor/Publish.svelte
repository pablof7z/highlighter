<script lang="ts">
	import VideoLink from "$components/Events/VideoLink.svelte";
    import { event, nonSubscribersPreview, previewExtraContent, status } from "$stores/post-editor";
	import { NDKArticle, NDKKind, NDKVideo } from "@nostr-dev-kit/ndk";
    import { prepareEventsForTierPublish, publishOrSchedule, publishToTiers } from "$actions/publishToTiers";
	import { getSelectedTiers } from "$lib/events/tiers";
	import { publishAt, makePublicAfter, preview, view, selectedTiers } from "$stores/post-editor";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import PublishValidation from "./PublishValidation.svelte";
	import { Thread, prepareThreadForPublish } from "$utils/thread";
	import currentUser from "$stores/currentUser";
	import ThreadItem from "$components/Editor/ThreadEditor/ThreadItem.svelte";
	import { WarningItem } from "./warnings";
	import ShareImageUploader from "$components/ShareImageUploader.svelte";
	import { Check } from "phosphor-svelte";
	import { sleep } from "@sveu/shared";
	import { getAuthorUrl, urlFromEvent } from "$utils/url";
	import { ndk } from "$stores/ndk";
	import { newToasterMessage } from "$stores/toaster";

    $: if ($event instanceof NDKEvent && $currentUser) {
        $event.pubkey = $currentUser?.pubkey;
        $event.author = $currentUser;
    }

    let publishing = false;
    let published = false;

    const tiers = getSelectedTiers($selectedTiers);
    if (Object.values($selectedTiers).length === tiers.length) {
        $nonSubscribersPreview = false;
    }

    // this will generate and sign all the events that will be published
    async function prepareEvents() {
        console.log("calling prepareEvent");
        let eventsToPublish: NDKEvent[] = [];
        
        if (!$event) throw new Error("No event available");
        
        if ($event instanceof Thread) {
            eventsToPublish = await prepareThreadForPublish($event, $publishAt);
        } else {
            $event.content ??= "";
            
            // prepend and append extra content to the preview
            preparePreview();
            
            const [ eventForPublish, teaserForPublish ] = await prepareEventsForTierPublish(
                $event,
                $selectedTiers,
                {
                    ndk: $ndk,
                    teaserEvent: $nonSubscribersPreview ? $preview as NDKEvent : undefined,
                    publishAt: $publishAt
                }
            )

            if (!eventForPublish) throw new Error("Couldn't prepare main event");
            
            eventsToPublish = [eventForPublish];
            if (teaserForPublish) eventsToPublish.push(teaserForPublish);

            eventsToPublish = [...eventsToPublish, ...await preparePublicRelease(eventForPublish)];
        }

        console.log(`eventsToPublish has ${eventsToPublish.length} items`, eventsToPublish.map(e => e.rawEvent()));
        return eventsToPublish;

    }

    let authorUrl = "";
    if ($currentUser) getAuthorUrl($currentUser).then(u => authorUrl = u);

    function removeTags(event: NDKEvent, tags: string[]) {
        return event.tags.filter(tag => !tags.includes(tag[0]));
    }

    /**
     * If there is a public release this will return:
     * * deletion event of the preview
     * * update of the preview saying that the article is now on a new location
     * * update the f tags of the main event
     * @param mainEvent
     */
    async function preparePublicRelease(mainEvent: NDKEvent) {
        let events: NDKEvent[] = []
        
        if ($makePublicAfter && $preview) {
            // delete preview
            const publishDate = mainEvent.created_at! + ($makePublicAfter * 24 * 60 * 60);
            const deleteEvent = await $preview.delete(`Superseded by full article ${mainEvent.encode()}`, false);
            deleteEvent.created_at = publishDate;
            await deleteEvent.sign();
            events.push(deleteEvent);

            // update preview
            const newPreview = new NDKEvent($ndk, $preview.rawEvent());
            newPreview.content = "This is a subscribers-first article that has now been made publicly available on " + urlFromEvent(mainEvent, authorUrl, true);
            newPreview.id = ""; newPreview.sig = "";
            newPreview.created_at = publishDate;
            newPreview.tags = removeTags(newPreview, ["tier", "preview", "f", "h", "full"]);
            await newPreview.sign();
            events.push(newPreview);

            // Add free tier
            const newMainEvent = new NDKEvent($ndk, mainEvent.rawEvent());
            newMainEvent.tags = removeTags(newMainEvent, ["tier", "preview"]);
            newMainEvent.tags.push(["f", "Free"]);
            newMainEvent.id = ""; newMainEvent.sig = "";
            newMainEvent.created_at = publishDate;

            newMainEvent.removeTag("published_at");
            newMainEvent.tags.push(["published_at", newMainEvent.created_at!.toString()])
            await newMainEvent.sign();
            events.push(newMainEvent);
        }

        return events;
    }

    function preparePreview() {
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
        
        // add preview content
        if ($preview) {
            if ($previewExtraContent?.before) {
                $preview.content = $previewExtraContent.before + `\n\n\n` + $preview.content;
            }

            if ($previewExtraContent?.after) {
                $preview.content = $preview.content + `\n\n\n` + $previewExtraContent.after;
            }
        }
    }

    async function publish(events: NDKEvent[]) {
        try {
            for (let ev of events) {
                // slow down to prevent getting rate-limited
                publishOrSchedule(ev);
                await sleep(1);
            }
            published = true;
        } catch (e: any) {
            console.trace(e);
            newToasterMessage(e.message, "error");
            publishing = false;
            return;
        }

        publishing = false;

        $view = "published";
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

    // when canPublish is true, pu
    $: if (canPublish && warnings.length === 0 && publishing == false && !published) {
        publishing = true;

        prepareEvents().then(publish).finally(() => {
            publishing = false;
        })
    }
</script>

{#key statusLength}
    <PublishValidation bind:warnings bind:canPublish />
    {#key canPublish}
        {#if $event && $currentUser}
            {#if publishing}
                <h1>Publishing</h1>
            {:else if canPublish}
                <div class="mt-10">
                    <button class="button" on:click={() => warnings = []}>Continue</button>

                </div>
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
                <div class="md:min-w-[40rem] border border-white/20 rounded p-3">
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
