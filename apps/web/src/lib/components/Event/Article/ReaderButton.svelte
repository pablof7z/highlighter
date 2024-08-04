<script lang="ts">
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { NDKRelaySet, NDKSubscription, NostrEvent } from "@nostr-dev-kit/ndk";
	import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
	import { Button } from "$components/ui/button";
	import { Play, Stop } from "phosphor-svelte";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import TtsModal from '$modals/TTSModal.svelte';
    import { loadedMedia, togglePause } from '$stores/media';

    export let article: NDKArticle;
    /**
     * When this function is set, it will be called back instead
     * of showing the TTS modal.
     */
    export let onShow: (() => void) | undefined = undefined;

    let recordingEvents: NDKEventStore<NDKEvent> | undefined;

    $ndk.fetchEvents({ kinds: [5250 as number], ...article.filter()})
        .then((events) => {
            console.log({events})
            if (events.size === 0) return;
            const eventIds = Array.from(events).map(e => e.id);
            console.log({eventIds})
            recordingEvents = $ndk.storeSubscribe({ "#e": eventIds }, { closeOnEose: true })
        });


    let dvmSub: NDKSubscription | undefined;

    let isLoaded: boolean;

    $: isLoaded = $loadedMedia[0]?.eventId === article.id;

    async function togglePlay() {
        if (isLoaded) {
            togglePause();
            return;
        }
        
        if (onShow) {
            onShow();
        } else {
            openModal(TtsModal, { event: article })
        }
    }
</script>

<Button {...{variant: "secondary", ...$$props}} on:click={togglePlay}>
    {#if isLoaded}
        <Stop />
    {:else}
        <Play class="sm:w-5 w-3.5 sm:h-5 h-3.5" weight="fill" />
    {/if}
</Button>
