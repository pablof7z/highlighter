<script lang="ts">
	import ShareModal from "$modals/ShareModal.svelte";
	import NDK, { NDKArticle, NDKEvent, NDKRelay, NDKRelaySet, NDKSimpleGroup, NDKVideo } from "@nostr-dev-kit/ndk";
	import { derived, Readable, writable, Writable } from "svelte/store";
	import { layout } from "$stores/layout";
	import BlankState from "$components/PageElements/BlankState.svelte";
	import { openModal } from "$utils/modal";
	import { getEventUrl, urlFromEvent } from "$utils/url";
	import { CaretDown, ArrowRight, Check, X, CircleNotch } from "phosphor-svelte";
	import { Button } from "$components/ui/button";
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";
	import { publish, RelayPublishState } from "./actions/publish";
	import { generatePreviewContent } from "$utils/preview";
	import { ndk } from "$stores/ndk";
    import * as Collapsible from "$lib/components/ui/collapsible";
    import * as Tooltip from "$lib/components/ui/tooltip";
    import * as Studio from '$components/Studio';

    export let state: Writable<Studio.State<Studio.Type>>;
    export let authorUrl: string;

    $layout.header = undefined;
    $layout.title = "Publishing";

    let content: string;
    // const tags = $event instanceof NDKEvent ? $event!.getMatchingTags("t") : [];
    // generateShareModalContent().then(c => content = c ?? "");

    const relays = writable<Record<string, RelayPublishState>>({});

    const publishedToRelays = derived(relays, $relays => {
        const e = Object.values($relays).filter(r => r.mainEvent === 'published').length
        const p = Object.values($relays).filter(r => r.previewEvent === 'published').length
        return e + p;
    });
    const failedToPublish = derived(relays, $relays => {
        const e = Object.values($relays).filter(r => r.mainEvent instanceof Error).length
        const p = Object.values($relays).filter(r => r.previewEvent instanceof Error).length
        return e + p;
    });
    const pendingRelays = derived(relays, $relays => {
        const e = Object.values($relays).filter(r => r.mainEvent === 'publishing').length
        const p = Object.values($relays).filter(r => r.previewEvent === 'publishing').length
        return e + p;
    });

    let publishedEvent: NDKArticle | NDKVideo | NDKEvent | undefined;

    onMount(async () => {
        if ($state.type === 'thread') {
            alert('thread publishing not implemented');
        } else {
            publish(
                state,
                relays
            ).then(() => {
                publishedEvent = Studio.getEventFromState($state);
            });

            // Studio.publish(
            //     $state,

            // );
        }
        
        // if ($event) {
        //     if ($withPreview && $publishScope === 'private' && !$preview) {
        //         if ($type === "article" && $event instanceof NDKArticle) {
        //             $preview = new NDKArticle($ndk);
        //             $preview.title = $event.title;
        //             $preview.content = generatePreviewContent($event);
        //         }
        //     }

        //     // Get main event relays
        //     const mainRelaySet = await getRelaySet($event, $publishInGroups, $publishScope, false);
        

        //     // Get preview event relays
        //     let previewRelaySet: NDKRelaySet | undefined;
        //     if ($preview) {
        //         previewRelaySet = await getRelaySet($preview, $publishInGroups, $publishScope, true);
        //         for (const relay of previewRelaySet.relays) {
        //             $relays[relay.url] ??= { event: false, preview: undefined };
        //             $relays[relay.url].preview = undefined;
        //         }

        //         console.table('preview relays', $relays);
        //     } else {
        //         console.log('no preview');
        //     }

        //     $event.on("relay:published", onEventPublish('event'));
        //     $event.on("relay:publish:failed", onPublishFail('event'));
            
        //     if ($preview) {
        //         $preview.on("relay:published", onEventPublish('preview'));
        //         $preview.on("relay:publish:failed", onPublishFail('preview'));
        //     }

        //     try {
        //         await publish(
        //             $event,
        //             $preview,
        //             $publishInGroups,
        //             $publishAt,
        //             $publishScope,
        //             $publishInTiers,
        //             mainRelaySet,
        //             previewRelaySet
        //         )
        //     } finally {
        //         console.log('back')

        //         // go through all $relays and mark any event or preview that is still undefined as new Error("Aborted")
        //         relays.update(val => {
        //             for (const [url, status] of Object.entries(val)) {
        //                 if (status.event === undefined) status.event = new Error("Aborted");
        //                 if ($preview && status.preview === undefined) status.preview = new Error("Aborted");
        //             }
        //             return val;
        //         })
        //     }
        // } else if ($thread) {
        //     try {
        //         const relaySet = getRelaySet($thread.items[0].event, $publishInGroups, $publishScope, false);
                
        //         await publishThread(
        //             $thread,
        //             $publishInGroups,
        //             $publishAt,
        //             $publishScope,
        //             $publishInTiers,
        //             relaySet
        //         );
        //     } finally {
        //         // go through all $relays and mark any event or preview that is still undefined as new Error("Aborted")
        //         relays.update(val => {
        //             for (const [url, status] of Object.entries(val)) {
        //                 if (status.event === undefined) status.event = new Error("Aborted");
        //             }
        //             return val;
        //         })
        //     }
        // }

        // console.table(relays);
    })

    function generateShareModalContent(event: NDKArticle | NDKVideo | NDKEvent) {
        if (event instanceof NDKArticle) {
            const parts = [ `I just published a new read on Nostr!\n`];
            if (event.title) parts.push(event.title);
            if (event.summary) parts.push(event.summary + "\n");

            const url = urlFromEvent(event, authorUrl, true, 0);

            parts.push(`Check it out: ${url}`);

            event.tags.forEach(([key, value]) => {
                const tags = [];
                if (key === "t") {
                    tags.push(`#${value}`);
                }
                if (tags.length) parts.push(tags.join(" "));
            });

            return parts.join("\n\n");
        } else if (event instanceof NDKVideo) {
            return `I just published a new video on Nostr! Check it out: ${event.title}`;
        } else {
            return `I just published a new event on Nostr! Check it out: ${event.encode()}`;
        }
    }

    function share() {
        let e: NDKEvent | undefined;

        e = Studio.getShareableEvent($state);
        if (!e) return;

        const content = generateShareModalContent(e);
        const tags = e.getMatchingTags("t");
        
        openModal(ShareModal, { event: e, content, tags });
    }
</script>


{#if $state.type === "thread"}
    <!-- <BlankState
        cta={$publishAt ? "View preview" : "View"}
        on:click={() => {
            if ($publishAt) goto('/schedule');
            else goto(`/a/${$thread.items[0].event.encode()}`);
        }}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
    >
        <img src="/images/published.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />

        <span class="text-2xl font-medium">
            Your thread
            {#if $publishAt}
                was scheduled!
            {:else}
                was published!
            {/if}
        </span>
    </BlankState> -->
{:else}
    <BlankState
        cta="Share your work"
        on:click={share}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
        >
        <img src="/images/published.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <div slot="afterCta">
            <!-- {#if $preview && $makePublicIn}
                <p class="mt-6 text-sm text-center">
                    <Check class="inline text-green-500 mr-2" />
                    In {$makePublicIn} days, this {$type} will be publicly available.
                </p>
            {/if} -->

            {#if !$state.publishAt && publishedEvent?.title}
                <div class="flex flex-row items-center gap-4">
                    <Button variant="secondary" href={getEventUrl(publishedEvent)}>
                        {publishedEvent.title}
                        <ArrowRight class="w-5 h-5 ml-2" />
                    </Button>
                </div>
            {/if}

            <!-- <blockquote class="app-quote relative my-8">
                <p class="z-1 relative text-foreground/60 text-lg">
                    “And what can life be worth if the first rehearsal for life is life itself? That is why life is always like a sketch. No, "sketch" is not quite a word, because a sketch is an outline of something, the groundwork for a picture, whereas the sketch that is our life is a sketch for nothing, an outline with no picture.”
                </p>

                <div class="author">
                    Milan Kundera
                </div>
            </blockquote> -->
        </div>

        <span class="text-2xl font-medium">
            <!-- {#if $event.title}
                <div class="font-extrabold text-3xl">{$event.title}</div>
            {:else} -->
                Your {$state.type}
            <!-- {/if} -->
            {#if $state.publishAt}
                was scheduled!
            {:else}
                was published!
            {/if}
        </span>

        <br>
        <span class="font-light opacity-80">
            Announce it to get the word out.
        </span>

        <Collapsible.Root class="my-6">
            <Collapsible.Trigger asChild let:builder>
                <Button builders={[builder]} variant="outline" class="w-full text-muted-foreground text-lg h-auto flex flex-row">
                    <div class="w-full grow text-left">
                        Publish status
                    </div>

                    <div class="flex flex-row gap-2 text-sm items-center text-muted-foreground font-normal divide-x divide-muted-foreground mr-2">
                        <span class="px-2">
                            {$publishedToRelays} <Check class="text-green-500 inline" />

                        </span>
                        {#if $failedToPublish > 0}
                            <span class="px-2">
                                {$failedToPublish} <X class="text-red-500 inline" />
                            </span>
                        {/if}
                        {#if $pendingRelays > 0}
                            <span class="px-2">
                                {$pendingRelays} <CircleNotch class="animate-spin text-muted-foreground inline" />
                            </span>
                        {/if}
                    </div>
                    <CaretDown class="h-4 w-4" />
                    <span class="sr-only">Toggle</span>
                </Button>
            </Collapsible.Trigger>
            <Collapsible.Content class="px-4 flex flex-col gap-1">
                {#each Object.entries($relays) as [ relayUrl, status ] (relayUrl)}
                    <div class="flex flex-row justify-between items-stretch gap-2 w-full text-sm">
                        <span class="text-foreground grow text-left">
                            {relayUrl}
                        </span>

                        <div class="w-12 flex justify-end">
                            {#if status.mainEvent === 'published'}
                                <Check class="text-green-500" />
                            {:else if status.mainEvent === false}
                                <!-- False means it's not supposed to be published here -->
                            {:else if status.mainEvent instanceof Error}
                                <Tooltip.Root>
                                    <Tooltip.Trigger>
                                        <X class="text-red-500" />
                                    </Tooltip.Trigger>
                                    <Tooltip.Content>
                                        <span class="text-red-500">
                                            {status.mainEvent.message}
                                        </span>
                                    </Tooltip.Content>
                                </Tooltip.Root>
                            {:else}
                                <CircleNotch class="animate-spin text-muted-foreground" />
                            {/if}
                        </div>

                        {#if $state.preview}
                            <div class="w-12 flex justify-end">
                                {#if status.previewEvent === 'published'}
                                    <Check class="text-green-500" />
                                {:else if status.previewEvent === false}
                                    <!-- False means it's not supposed to be published here -->
                                {:else if status.previewEvent instanceof Error}
                                    <Tooltip.Root>
                                        <Tooltip.Trigger>
                                            <X class="text-red-500" />
                                        </Tooltip.Trigger>
                                        <Tooltip.Content>
                                            <span class="text-red-500">
                                                {status.previewEvent.message}
                                            </span>
                                        </Tooltip.Content>
                                    </Tooltip.Root>
                                {:else}
                                    <CircleNotch class="animate-spin text-muted-foreground" />
                                {/if}
                            </div>
                        {/if}
                    </div>
                {/each}
            </Collapsible.Content>
        </Collapsible.Root>
        
    </BlankState>
{/if}