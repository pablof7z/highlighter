<script lang="ts">
	import { prepareEventsForTierPublish, publishToTiers } from "$actions/publishToTiers";
	import FeedGroupPost from "$components/Feed/FeedGroupPost.svelte";
	import TiersLabel from "$components/Forms/TiersLabel.svelte";
	import Box from "$components/PageElements/Box.svelte";
	import { dvmScheduleEvent } from "$lib/dvm";
	import { getSelectedTiers } from "$lib/events/tiers";
	import { type, publishAt, makePublicAfter, preview, view, selectedTiers } from "$stores/post-editor";
	import { NDKEvent, type NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { Check, Info } from "phosphor-svelte";

    export let article: NDKArticle | undefined = undefined;
    export let video: NDKEvent | undefined = undefined;
    export let note: NDKEvent | undefined = undefined;
    export let schedule = false;

    let event = article ?? video ?? note!;
    let eventPublished = false;
    let previewPublished = false;
    let makePublicScheduled = false;
    let publishAtVal: string | undefined = $publishAt?.toISOString().slice(0, -1);

    $: if (publishAtVal) {
        try {
            const date = new Date(publishAtVal);
            if (date.getTime() > Date.now()) { $publishAt = date; }
        } catch(e) { console.log(e) }
    }

    async function publish() {
        const tiers = getSelectedTiers($selectedTiers);

        if (Object.values($selectedTiers).length === tiers.length) {
            $preview = undefined;
        }

        const [ eventForPublish, teaserForPublish ] = await prepareEventsForTierPublish(
            event,
            $selectedTiers,
            {
                ndk: $ndk,
                teaserEvent: $preview as NDKEvent,
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
            newToasterMessage(e.message, "error");
            return;
        }

        if ($makePublicAfter && $preview) {
            // Publish a delete of the preview
            const publishDate = event.created_at! + ($makePublicAfter * 24 * 60 * 60);
            const deleteEvent = await $preview.delete(`Superseded by full article ${event.encode()}`);
            deleteEvent.created_at = publishDate;
            await deleteEvent.sign();
            await dvmScheduleEvent(deleteEvent);

            // Remove all tier mentions from event
            const tagsToRemove = ["tier", "f", "preview"]
            event.tags = event.tags.filter(tag => !tagsToRemove.includes(tag[0]));
            for (const tier of Object.keys($selectedTiers)) {
                event.tags.push(["f", tier]);
            }
            event.id = "";
            event.sig = "";
            event.created_at! += $makePublicAfter * 24 * 60 * 60;
            await event.sign();
            // console.log("scheduling event", event.rawEvent());
            await dvmScheduleEvent(event);
            makePublicScheduled = true;
        }

        $view = "published";
    }

    let timeToPublish = 0;

    $: timeToPublish = $publishAt ? new Date($publishAt).getTime() - Date.now() : 0;
</script>

<Box title="Publishing">
    <div class="flex flex-col w-full gap-2 p-4 bg-white/5 rounded-box">
        {#if article}
            {#if !article.image || !article.summary}
                <div class="flex flex-col sm:flex-row gap-4 justify-between">
                    <div class="flex flex-row items-center">
                    <Info size={24} class="inline mr-2" />
                    Article is missing a cover or summary.
                    </div>
                    <button class="button" on:click={() => $view = 'meta'}>
                        Edit article attributes
                    </button>
                </div>
            {/if}
        {:else if note}
            <FeedGroupPost event={note} />
        {/if}
    </div>

    {#if $preview}
        <Box>
            <div>
                <Check class="w-4 h-4 inline mr-2 {eventPublished ? "text-success" : ""}" />
                Publish {$type} to tiers: <TiersLabel tiers={$selectedTiers} />
            </div>

            {#if $preview}
                <div>
                    <Check class="w-4 h-4 inline mr-2 {previewPublished ? "text-success" : ""}" />
                    A preview
                    will be
                    published
                </div>

                {#if $makePublicAfter}
                    <div>
                        <Check class="w-4 h-4 inline mr-2 {makePublicScheduled ? "text-success" : ""}" />
                        Article will be made public after {$makePublicAfter} days
                    </div>
                {/if}
            {/if}
        </Box>
    {/if}


    {#if schedule}
        <section class="settings w-full my-10">
            <div class="title">
                Schedule publication
            </div>
            <div class="field">
                <div class="title">Publish at</div>
                <input type="datetime-local" bind:value={publishAtVal} class="input rounded-full !bg-white/5" />
                {#if $publishAt}
                    <span class="text-sm text-neutral-500">
                        This {$type} will be published
                        <RelativeTime timestamp={$publishAt.getTime()} />
                        {#if $makePublicAfter}
                            and made public {$makePublicAfter} days after
                        {/if}
                    </span>
                {/if}
            </div>

            <div class="flex flex-row gap-4 items-stretch w-full justify-between">
                <button class="text-white px-10" on:click={() => {
                    $publishAt = undefined;
                    publish();
                }}>
                    Publish Now
                </button>

                <button class="button button-primary px-10 text-white" on:click={publish} disabled={!$publishAt || new Date($publishAt) < new Date()}>
                    Schedule
                </button>
            </div>
        </section>

    {:else}
        <div class="flex flex-row gap-4 items-center w-full justify-center my-10">
            <button class="button button-primary px-10" on:click={publish}>
                Publish Now
            </button>
        </div>
    {/if}
</Box>