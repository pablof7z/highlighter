<script lang="ts">
	import ShareModal from "$modals/ShareModal.svelte";
	import { DraftItem } from "$stores/drafts";
	import { Thread } from "$utils/thread";
    import { Mode, PublishInGroupStore, PublishInTierStore, Scope, Types as StudioItemTypes } from "$components/Studio";
	import { NDKArticle, NDKEvent, NDKRelay, NDKRelaySet, NDKSimpleGroup, NDKVideo } from "@nostr-dev-kit/ndk";
	import { derived, Readable, writable, Writable } from "svelte/store";
	import { layout } from "$stores/layout";
	import BlankState from "$components/PageElements/BlankState.svelte";
	import { openModal } from "$utils/modal";
	import { urlFromEvent } from "$utils/url";
	import { CaretDown, ArrowRight, Check, X, CircleNotch } from "phosphor-svelte";
	import { Button } from "$components/ui/button";
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";
	import { getRelaySet, publish } from "./actions/publish";
	import { generatePreviewContent } from "$utils/preview";
	import { ndk } from "$stores/ndk";
    import * as Collapsible from "$lib/components/ui/collapsible";
    import * as Tooltip from "$lib/components/ui/tooltip";

    export let groups: Readable<Record<string, NDKSimpleGroup>>;
    export let event: Writable<NDKArticle | NDKVideo | undefined>;
    export let preview: Writable<NDKArticle | NDKVideo | undefined>;
    export let thread: Writable<Thread | undefined>;
    export let withPreview: Writable<boolean>;

    export let mode: Writable<Mode>;
    export let type: Writable<StudioItemTypes>;
    
    export let draft: DraftItem | undefined = undefined;
    export let publishInGroups: PublishInGroupStore;
    export let publishInTiers: PublishInTierStore;
    export let publishAt: Writable<Date | undefined>;
    export let publishScope: Writable<Scope>;

    export let authorUrl: string;
    export let makePublicIn: Writable<Date | undefined>;

    $layout.header = undefined;
    $layout.title = "Publishing";

    let content: string;
    const tags = $event instanceof NDKEvent ? $event!.getMatchingTags("t") : [];
    generateShareModalContent().then(c => content = c ?? "");

    const relays = writable<Record<WebSocket["url"], { event: true | undefined | Error, preview: true | undefined | Error }>>({});

    const publishedToRelays = derived(relays, $relays => {
        const e = Object.values($relays).filter(r => r.event === true).length
        const p = Object.values($relays).filter(r => r.preview === true).length
        return e + p;
    });
    const failedToPublish = derived(relays, $relays => {
        const e = Object.values($relays).filter(r => r.event instanceof Error).length
        const p = Object.values($relays).filter(r => r.preview instanceof Error).length
        return e + p;
    });
    const pendingRelays = derived(relays, $relays => {
        const e = Object.values($relays).filter(r => r.event === undefined).length
        const p = Object.values($relays).filter(r => r.preview === undefined).length
        return e + p;
    });

    const onEventPublish = (type: 'event' | 'preview') => (relay: NDKRelay) => {
        console.log('published on relay', relay.url);
        if (!relay?.url) {
            console.trace('called without relay', relay)
            return;
        }
        if (!$relays[relay.url]) $relays[relay.url] = { event: undefined, preview: undefined };
        $relays[relay.url][type] = true;
    }

    const onPublishFail = (type: 'event' | 'preview') => (relay: NDKRelay, error: Error) => {
        console.log('failed to publish on relay', relay.url, error);
        if (!relay?.url) {
            console.trace('called failed without relay', relay)
            return;
        }
        if (!$relays[relay.url]) $relays[relay.url] = { event: undefined, preview: undefined };
        $relays[relay.url][type] = error;
    }

    onMount(async () => {
        if ($event) {
            if ($withPreview && $publishScope === 'private' && !$preview) {
                if ($type === "article" && $event instanceof NDKArticle) {
                    $preview = new NDKArticle($ndk);
                    $preview.title = $event.title;
                    $preview.content = generatePreviewContent($event);
                }
            }

            // Get main event relays
            const mainRelaySet = await getRelaySet($event, $publishInGroups, $publishScope, false);
            for (const relay of mainRelaySet.relays) {
                $relays[relay.url] = { event: undefined, preview: false };
            }

            // Get preview event relays
            let previewRelaySet: NDKRelaySet | undefined;
            if ($preview) {
                previewRelaySet = await getRelaySet($preview, $publishInGroups, $publishScope, true);
                for (const relay of previewRelaySet.relays) {
                    $relays[relay.url] ??= { event: false, preview: undefined };
                    $relays[relay.url].preview = undefined;
                }

                console.table('preview relays', $relays);
            } else {
                console.log('no preview');
            }

            $event.on("relay:published", onEventPublish('event'));
            $event.on("relay:publish:failed", onPublishFail('event'));
            
            if ($preview) {
                $preview.on("relay:published", onEventPublish('preview'));
                $preview.on("relay:publish:failed", onPublishFail('preview'));
            }
            const relaySet = NDKRelaySet.fromRelayUrls(["ws://localhost:2929"], $ndk)

            try {
                await publish(
                    $event,
                    $preview,
                    $publishInGroups,
                    $publishAt,
                    $publishScope,
                    $publishInTiers,
                    mainRelaySet,
                    previewRelaySet
                )
            } finally {
                console.log('back')

                // go through all $relays and mark any event or preview that is still undefined as new Error("Aborted")
                relays.update(val => {
                    for (const [url, status] of Object.entries(val)) {
                        if (status.event === undefined) status.event = new Error("Aborted");
                        if ($preview && status.preview === undefined) status.preview = new Error("Aborted");
                    }
                    return val;
                })
            }
        }

        console.table(relays);
    })

    async function generateShareModalContent() {
        if (!$event) return;
        
        if ($event instanceof NDKArticle) {
            const parts = [ `I just published a new read on Nostr!`];
            if ($event.title) parts.push($event.title);
            if ($event.summary) parts.push($event.summary);

            const url = urlFromEvent($event, authorUrl, true);

            parts.push(`Check it out: ${url}`);

            return parts.join("\n\n");
        } else if ($event instanceof NDKVideo) {
            return `I just published a new video on Nostr! Check it out: ${$event.title}`;
        } else {
            return `I just published a new event on Nostr! Check it out: ${$event.encode()}`;
        }
    }

    function share() {
        let e: NDKEvent;

        if ($event instanceof NDKEvent) e = $event;
        
        openModal(ShareModal, { event: e, content, tags });
    }
</script>

{#if $type === "thread" && $thread}
    <BlankState
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
    </BlankState>
{:else if $event}
    <BlankState
        cta="Share your work"
        on:click={share}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
        >
        <img src="/images/published.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <div slot="afterCta">
            {#if $preview && $makePublicIn}
                <p class="mt-6 text-sm text-center">
                    <Check class="inline text-green-500 mr-2" />
                    In {$makePublicIn} days, this {$type} will be publicly available.
                </p>
            {/if}

            {#if !$publishAt}
                <div class="flex flex-row items-center gap-4">
                    <Button variant="secondary" href={urlFromEvent($event)}>
                        {$event.title}
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
            {#if $event.title}
                <div class="font-extrabold text-3xl">{$event.title}</div>
            {:else}
                Your {$type}
            {/if}
            {#if $publishAt}
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
                            {#if status.event === true}
                                <Check class="text-green-500" />
                            {:else if status.event === false}
                                <!-- False means it's not supposed to be published here -->
                            {:else if status.event instanceof Error}
                                <Tooltip.Root>
                                    <Tooltip.Trigger>
                                        <X class="text-red-500" />
                                    </Tooltip.Trigger>
                                    <Tooltip.Content>
                                        <span class="text-red-500">
                                            {status.event.message}
                                        </span>
                                    </Tooltip.Content>
                                </Tooltip.Root>
                            {:else}
                                <CircleNotch class="animate-spin text-muted-foreground" />
                            {/if}
                        </div>

                        {#if $preview}
                            <div class="w-12 flex justify-end">
                                {#if status.preview === true}
                                    <Check class="text-green-500" />
                                {:else if status.preview === false}
                                    <!-- False means it's not supposed to be published here -->
                                {:else if status.preview instanceof Error}
                                    <Tooltip.Root>
                                        <Tooltip.Trigger>
                                            <X class="text-red-500" />
                                        </Tooltip.Trigger>
                                        <Tooltip.Content>
                                            <span class="text-red-500">
                                                {status.preview.message}
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