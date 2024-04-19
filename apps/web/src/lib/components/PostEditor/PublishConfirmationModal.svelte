<script lang="ts">
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
	import RadioButton from "$components/Forms/RadioButton.svelte";
    import ModalShell from "$components/ModalShell.svelte";
    import { event, event, nonSubscribersPreview, previewExtraContent, reset, status } from "$stores/post-editor";
	import { NDKArticle, NDKKind, NDKVideo } from "@nostr-dev-kit/ndk";
	import { closeModal } from "svelte-modals";
    import { prepareEventsForTierPublish, publishToTiers } from "$actions/publishToTiers";
	import { dvmScheduleEvent } from "$lib/dvm";
	import { getSelectedTiers } from "$lib/events/tiers";
	import { publishAt, makePublicAfter, preview, view, selectedTiers, wideDistribution } from "$stores/post-editor";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { debugMode } from "$stores/session";
	import PublishValidation from "./PublishValidation.svelte";
	import { Thread } from "$utils/thread";
	import currentUser from "$stores/currentUser";
	import ThreadItem from "$components/Editor/ThreadEditor/ThreadItem.svelte";
	import { goto } from "$app/navigation";

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

    async function publishThread(thread: Thread) {
        let rootEvent: NDKEvent | undefined;
        let lastEvent: NDKEvent | undefined;
        let lastPublishTime: number;
        const timestampEventsEvery = 5; // seconds

        // if publishAt is set, use it, in seconds
        if ($publishAt) {
            lastPublishTime = $publishAt.getTime() / 1000;
        } else {
            lastPublishTime = Math.floor(Date.now() / 1000); // now
        }

        for (const item of thread.items) {
            const event = item.event;
            event.id = "";
            event.sig = "";
            event.created_at = lastPublishTime;

            // next publish time should be in timestampEventsEvery seconds
            lastPublishTime += timestampEventsEvery;

            if (rootEvent) {
                // tag the current event with the root event
                event.tag(rootEvent, "root", true);

                // if we have a lastEvent, tag it, we're replying to it since this is a thread
                if (lastEvent) { event.tag(lastEvent, "reply", true); }
            }

            const [ eventForPublish ] = await prepareEventsForTierPublish(
                event,
                $selectedTiers,
                {
                    ndk: $ndk,
                    wideDistribution: true,
                    publishAt: $publishAt,
                    explicitCreatedAt: event.created_at
                }
            )

            if (!eventForPublish) {
                newToasterMessage("Failed to prepare event for publish", "error");
                return;
            };

            // sign, we need Ids
            await eventForPublish.sign();
            eventForPublish.rawEvent();

            if (!rootEvent) {
                rootEvent = eventForPublish;
            } else {
                lastEvent = eventForPublish;
            }

            await publishToTiers(
                eventForPublish, {
                    ndk: $ndk,
                    wideDistribution: true,
                    publishAt: $publishAt,
                }
            )
        }

        if (rootEvent) goto("/e/" + rootEvent.encode());
    }

    async function publish() {
        publishing = true;

        if (!$event) {
            publishing = false;
            return;
        }

        if ($event instanceof Thread) {
            return publishThread($event);
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
                wideDistribution: $wideDistribution,
                publishAt: $publishAt
            }
        )

        try {
            await publishToTiers(
                eventForPublish!, {
                    ndk: $ndk,
                    teaserEvent: teaserForPublish as NDKEvent,
                    wideDistribution: $wideDistribution,
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
            $event.sig = "";
            $event.created_at! += $makePublicAfter * 24 * 60 * 60;
            $event.removeTag("published_at");
            await $event.sign();
            console.log("scheduling event", $event.rawEvent());
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
</script>

<ModalShell color="glassy" class="max-w-3xl">
    <h1 class="text-center font-white text-2xl font-medium">
        Ready to publish?
    </h1>

    {#key statusLength}
        <PublishValidation bind:canPublish />
        {#key canPublish}
            {#if $event && $currentUser}
                {#if $event.kind === NDKKind.Article}
                    <div class="md:min-w-[40rem] border border-white/20 rounded-box p-3">
                        <ArticleLink article={$event} skipLink={true} />
                    </div>
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

    <section class="settings !bg-transparent !p-0 w-full">
        <div class="field">
            <div class="title">Publication</div>

            <div class="w-full rounded-box overflow-clip">
                <RadioButton bind:currentValue={mode} value="now" class="flex-1 bg-white/10 !text-white font-normal text-xl ">
                    Publish now
                </RadioButton>

                <RadioButton bind:currentValue={mode} value="schedule" class="flex-1 bg-white/10 !text-white font-normal text-xl" on:click={() => dateInput.focus()}>
                    Schedule
                    <div slot="description" class:hidden={mode !== "schedule"}>
                        <input type="datetime-local" bind:value={publishAtVal} class="border-none !bg-transparent placeholder:text-black text-black" bind:this={dateInput} />
                    </div>
                </RadioButton>
            </div>
        </div>
    </section>

    {#if $debugMode}
        <div class="max-w-xl overflow-auto">
            {#if $nonSubscribersPreview}
                Preview
                <pre>{JSON.stringify($preview?.rawEvent())}</pre>
            {/if}
            Event
            <pre>{JSON.stringify($event?.rawEvent())}</pre>
        </div>
        <div>wideDistribution: {$wideDistribution}</div>
        <div>nonSubscribersPreview: {$nonSubscribersPreview}</div>
    {/if}

    <div class="flex flex-row gap-4 w-full">
        <button on:click={() => closeModal()}>
            Back
        </button>

        <button
            class="button flex-1 px-10 py-3"
            disabled={mode === 'schedule' && (!$publishAt || new Date($publishAt) < new Date()) || !canPublish || publishing}
            on:click={() => {
                if (mode === "now") $publishAt = undefined;
                publish();
            }}
        >
            {#if publishing}
                <div class="loading loading-sm"></div>
            {:else}
                {#if mode === "now"}
                    Publish Now
                {:else}
                    Schedule
                {/if}
            {/if}
        </button>
    </div>
</ModalShell>