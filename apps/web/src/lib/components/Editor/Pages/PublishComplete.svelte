<script lang="ts">
	import { openModal } from '$utils/modal';
	import ShareModal from '$modals/ShareModal.svelte';
	import { event, makePublicAfter, preview, publishAt, type } from '$stores/post-editor';
	import BlankState from '$components/PageElements/BlankState.svelte';
	import { NDKArticle, NDKEvent, NDKVideo } from '@nostr-dev-kit/ndk';
	import currentUser from '$stores/currentUser';
	import { getAuthorUrl, urlFromEvent } from '$utils/url';
	import Thread from '$components/Drafts/Items/Thread.svelte';
	import { isScheduledEvent } from '$utils/schedule';
	import { goto } from '$app/navigation';
	import { Check } from 'phosphor-svelte';

    export let title: string | undefined = "undefined";
    export let shareUrl: string | undefined = "undefined";

    let content: string;
    const tags = $event instanceof NDKEvent ? $event!.getMatchingTags("t") : [];
    generateShareModalContent().then(c => content = c ?? "");

    async function generateShareModalContent() {
        if (!$event) return;
        
        if ($event instanceof NDKArticle) {
            const parts = [ `I just published a new read on Nostr!`];
            if ($event.title) parts.push($event.title);
            if ($event.summary) parts.push($event.summary);

            const authorUrl = await getAuthorUrl($currentUser!);
            const url = urlFromEvent($event, authorUrl, true);

            parts.push(`Check it out: ${url}`);

            return parts.join("\n\n");
        } else if ($event instanceof NDKVideo) {
            return `I just published a new video on Nostr! Check it out: ${$event.title}`;
        } else {
            return `I just published a new event on Nostr! Check it out: ${$event.encode()}`;
        }
    }

    let scheduled = false;  

    if ($event instanceof NDKEvent) {
        scheduled = isScheduledEvent($event);
    } else if ($event instanceof Thread) {
        scheduled = isScheduledEvent($event.items[0].event);
    }

    function share() {
        let e: NDKEvent;

        if ($event instanceof NDKEvent) e = $event;
        
        openModal(ShareModal, { event: e, content, tags });
    }
</script>

{#if $type === "thread"}
    <BlankState
        cta={scheduled ? "View preview" : "View"}
        on:click={() => {
            if (scheduled) goto('/schedule');
            else goto(`/e/${$event.items[0].event.encode()}`);
        }}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
    >
        <img src="/images/published.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <blockquote slot="afterCta" class="app-quote relative my-8">
            <p class="z-1 relative text-white/60 text-lg">
                “And what can life be worth if the first rehearsal for life is life itself? That is why life is always like a sketch. No, "sketch" is not quite a word, because a sketch is an outline of something, the groundwork for a picture, whereas the sketch that is our life is a sketch for nothing, an outline with no picture.”
            </p>

            <div class="author">
                Milan Kundera
            </div>
        </blockquote>

        <span class="text-2xl font-medium">
            Your thread
            {#if scheduled}
                was scheduled!
            {:else}
                was published!
            {/if}
        </span>
    </BlankState>
{:else}
    <BlankState
        cta="Share your work"
        on:click={share}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
    >
        <img src="/images/published.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <div slot="afterCta">
            {#if $preview && $makePublicAfter}
                <p class="mt-6 text-sm text-center">
                    <Check class="inline text-green-500 mr-2" />
                    In {$makePublicAfter} days, this {$type} will be publicly available.
                </p>
            {/if}

            <blockquote class="app-quote relative my-8">
                <p class="z-1 relative text-white/60 text-lg">
                    “And what can life be worth if the first rehearsal for life is life itself? That is why life is always like a sketch. No, "sketch" is not quite a word, because a sketch is an outline of something, the groundwork for a picture, whereas the sketch that is our life is a sketch for nothing, an outline with no picture.”
                </p>

                <div class="author">
                    Milan Kundera
                </div>
            </blockquote>
        </div>
        
        <span class="text-2xl font-medium">
            {#if $event.title}
                <div class="font-extrabold text-3xl">{$event.title}</div>
            {:else}
                Your {$type}
            {/if}
            {#if scheduled}
                was scheduled!
            {:else}
                was published!
            {/if}
        </span>

        <br>
        <span class="font-light opacity-80">
            Announce it to your audience to get the word out.
        </span>
    </BlankState>
{/if}