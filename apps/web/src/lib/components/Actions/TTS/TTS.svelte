<script lang="ts">
import { ndk } from "$stores/ndk";
	import { NDKAppHandlerEvent, NDKArticle, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { requestTTS } from '$utils/dvms/request-tts';
	import currentUser from '$stores/currentUser';
	import { createEventDispatcher } from "svelte";
	import { NavigationOption } from "../../../../app";
	import ServiceItem from "../../../../routes/settings/(page)/services/ServiceItem.svelte";

    export let event: NDKEvent;
    export let forceSend = false;

    const dispatch = createEventDispatcher();

    $: if (forceSend) {
        forceSend = false;
        sendReq();
    }

    const ttsDvms = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.DVMReqTextToSpeech.toString()] },
        { closeOnEose: true },
        NDKAppHandlerEvent
    )
    
    const results = $ndk.storeSubscribe(
        { kinds: [NDKKind.DVMReqTextToSpeech+1000], "#i": [event.id] }
    )

    let actionButtons: NavigationOption[] = [];

    $: actionButtons = [
        { name: "Request text-to-speech", fn: sendReq }
    ]

    async function sendReq() {
        dispatch("done");
        requestTTS(NDKArticle.from(event), dvmPubkey);
    }

    let dvmPubkey: string;
    
</script>

{#each $results as result}
    {#if result.tagValue("p") !== $currentUser?.pubkey}
        Add to your podcast feed
    {/if}
    <EventWrapper
        event={result}
        skipItemLinkPreview
        compact
    />
{/each}

<ServiceItem
    title="Text to speech service"
    bind:dvmPubkey
    kind={NDKKind.DVMReqTextToSpeech}
    eventId="nevent1qqsvwvwzdqnxnh8ujff23vegtqa8mjkkrr93alqs52wgyjk8wd8vrkg9xddws"
/>
