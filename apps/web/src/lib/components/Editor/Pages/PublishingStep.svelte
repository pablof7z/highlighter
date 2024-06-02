<script lang="ts">
	import { openModal } from '$utils/modal';
	import ShareModal from '$modals/ShareModal.svelte';
	import { event } from '$stores/post-editor';
	import BlankState from '$components/PageElements/BlankState.svelte';
	import { NDKArticle, NDKVideo } from '@nostr-dev-kit/ndk';
	import currentUser from '$stores/currentUser';
	import { getAuthorUrl, urlFromEvent } from '$utils/url';

    export let title: string | undefined = "undefined";
    export let shareUrl: string | undefined = "undefined";

    let content: string;
    const tags = $event!.getMatchingTags("t");
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
</script>

<BlankState
    cta="Share your work"
    on:click={() => openModal(ShareModal, { event: $event, content, tags })}
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
        {#if $event.title}
            <div class="font-extrabold text-3xl">{$event.title}</div>
        {:else}
            Your work
        {/if}
        was published!
    </span>
    <br>
    <span class="font-light opacity-80">
        Announce it to your audience to get the word out.
    </span>
</BlankState>
    
    <!-- <div class="max-w-sm mx-auto w-full">
        <LottiePlayer
            src="/images/done.json"
            autoplay={true}
            loop={false}
            controls={false}
            renderer="svg"
            background="transparent"
            speed={0.5}
        />
    </div> -->

    <!-- <h1>
        {$event?.title??"Your post"} was published!
    </h1> -->

    <!-- <button class="button" on:click={() => openModal(ShareModal, { event: $event })}>
        <Export class="w-6 h-6" />
    </button> -->