<script lang="ts">
	import { ActionsButton } from 'konsta/svelte';
	import ModalShell from "$components/ModalShell.svelte";
import { ndk } from "$stores/ndk";
	import { NDKAppHandlerEvent, NDKArticle, NDKEvent, NDKKind, NDKSubscription } from "@nostr-dev-kit/ndk";
	import ServiceItem from "../../routes/settings/(page)/services/ServiceItem.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { onDestroy } from "svelte";
	import { NavigationOption } from '../../app';
	import { action, closeModal } from 'svelte-modals';
	import { requestTTS } from '$utils/dvms/request-tts';
	import currentUser from '$stores/currentUser';

    export let event: NDKEvent;

    const ttsDvms = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.DVMReqTextToSpeech.toString()] },
        { closeOnEose: true },
        NDKAppHandlerEvent
    )

    // let subscriptions: NDKSubscription[] = [];
    // let results:

    // const requests = $ndk.storeSubscribe(
    //     { kinds: [NDKKind.DVMReqTextToSpeech], ...event.filter() },
    //     {
    //         onEvent: (e) => {
    //             const sub = $ndk.subscribe(
    //                 {kinds: [NDKKind.DVMReqTextToSpeech+1000, 7000], "#e": [e.id]},
    //                 { groupable: true, groupableDelayType: 'at-least', subId: 'dvm-results' }
    //             )
    //             sub.on("event", 
    //             subscriptions.push(sub);
    //         }
    //     }
    // )

    // onDestroy(() => {
    //     for (const sub of subscriptions) {
    //         sub.stop();
    //     }
    // })

    const results = $ndk.storeSubscribe(
        { kinds: [NDKKind.DVMReqTextToSpeech+1000], "#i": [event.id] }
    )

    let actionButtons: NavigationOption[] = [];

    $: actionButtons = [
        { name: "Request text-to-speech", fn: sendReq }
    ]

    async function sendReq() {
        closeModal();
        requestTTS(NDKArticle.from(event), dvmPubkey);
    }

    let dvmPubkey: string;
    
</script>

<ModalShell
    title="Text-to-speech"
    class="max-w-3xl"
    {actionButtons}
>
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
    
    <!-- {#each $ttsDvms as dvm}
        {#await dvm.fetchProfile() then profile}
            {profile?.name}
        {/await}
    {/each} -->
</ModalShell>