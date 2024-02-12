<script lang="ts">
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
	import RadioButton from "$components/Forms/RadioButton.svelte";
    import ModalShell from "$components/ModalShell.svelte";
    import { event, previewExtraContent, reset } from "$stores/post-editor";
	import { user } from "@kind0/ui-common";
	import { NDKKind } from "@nostr-dev-kit/ndk";
	import { closeModal } from "svelte-modals";
    import { prepareEventsForTierPublish, publishToTiers } from "$actions/publishToTiers";
	import { dvmScheduleEvent } from "$lib/dvm";
	import { getSelectedTiers } from "$lib/events/tiers";
	import { publishAt, makePublicAfter, preview, view, selectedTiers, wideDistribution } from "$stores/post-editor";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    $: if ($event && $user) {
        $event.pubkey = $user?.pubkey;
        $event.author = $user;
    }

    let mode: "now" | "schedule" = "now";

    let publishing = false;
    let eventPublished = false;
    let previewPublished = false;
    let makePublicScheduled = false;
    let publishAtVal: string | undefined = $publishAt?.toISOString().slice(0, -1);

    $: $wideDistribution = false;

    $: if (publishAtVal) {
        try {
            const date = new Date(publishAtVal);
            if (date.getTime() > Date.now()) { $publishAt = date; }
        } catch(e) { console.log(e) }
    }

    async function publish() {
        publishing = true;
        const tiers = getSelectedTiers($selectedTiers);

        if (!$event) {
            publishing = false;
            return;
        }

        if (Object.values($selectedTiers).length === tiers.length) {
            $preview = undefined;
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
                teaserEvent: $preview as NDKEvent,
                wideDistribution: $wideDistribution,
                publishAt: $publishAt
            }
        )

        console.log("eventForPublish", eventForPublish?.rawEvent());
        console.log("teaserForPublish", teaserForPublish?.rawEvent());

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

        closeModal();
        reset("published");
        publishing = false;
    }

    let timeToPublish = 0;

    $: timeToPublish = $publishAt ? new Date($publishAt).getTime() - Date.now() : 0;

    let dateInput: HTMLInputElement;
</script>

<ModalShell color="glassy" class="max-w-3xl">
    <h1 class="text-center font-white text-2xl font-medium">
        Ready to publish?
    </h1>

    <div class="md:min-w-[40rem]">
        {#if $event && $user}
            {#if $event.kind === NDKKind.Article}
                <ArticleLink article={$event} skipLink={true} />
            {:else if $event.kind === NDKKind.HorizontalVideo}
                <VideoLink video={$event} skipLink={true} />
            {/if}
        {/if}
    </div>

    <section class="settings !bg-transparent !p-0 w-full">
        <div class="field">
            <div class="title">Publication</div>

            <RadioButton bind:currentValue={mode} value="now" class="flex-1 bg-white/10 !text-white font-normal text-xl">
                Publish now
            </RadioButton>

            <RadioButton bind:currentValue={mode} value="schedule" class="flex-1 bg-white/10 !text-white font-normal text-xl" on:click={() => dateInput.focus()}>
                Schedule
                <div slot="description">
                    <input type="datetime-local" bind:value={publishAtVal} class="border-none !bg-transparent" bind:this={dateInput} />
                </div>
            </RadioButton>
        </div>
    </section>

    <div>wideDistribution: {$wideDistribution}</div>

    <div class="flex flex-row gap-4 w-full">
        <button on:click={() => closeModal()}>
            Back
        </button>

        <button
            class="button flex-1 px-10 py-3"
            disabled={mode === 'schedule' && (!$publishAt || new Date($publishAt) < new Date())}
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