<script lang="ts">
	import { nip19 } from 'nostr-tools';
	import LnQrCode from "$components/Payment/LnQrCode.svelte";
    import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import DvmInput from "./DvmInput.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import { Play } from "phosphor-svelte";
	import { Button } from "$components/ui/button";
    import { play } from "$stores/media";

    export let event: NDKEvent;
    export let skipItemLinkPreview = false;

    const request = event.tagValue('request');
    let title: string | undefined;
    let url: string | undefined;
    let eventId: string | undefined;

    const input = event.tagValue("i");
    eventId = input;
    if (input) {
        try {
            const neventEncode = nip19.neventEncode(input)
            url = "/a/" + neventEncode;
        } catch {}
    }

    if (request) {
        try {
            const requestEvent = new NDKEvent(undefined, JSON.parse(request));
            title = requestEvent.tagValue('title');
        } catch {}
    }

    const isPaymentRequired = event.tagValue('status') === "payment-required"
    const [ _, amount, pr ] = event.getMatchingTags("amount")?.[0] || []

</script>

{#if !skipItemLinkPreview}
    {#each event.getMatchingTags("i") as inputTag}
        <DvmInput {inputTag} />
    {/each}
{/if}

{#if isPaymentRequired && pr}
    <LnQrCode {pr} satAmount={parseInt(amount)/1000} tryToPay={false} />
    <p>Payment required</p>
{/if}

{#if event.kind === NDKKind.DVMReqTextToSpeech+1000}
    <Button variant="secondary" on:click={(e) => {
        play({mediaUrl: event.content, title, url, eventId });
        e.stopImmediatePropagation();
        e.preventDefault();
    }}>
        <Play weight="fill" />
    </Button>
{:else}
    <EventContent ndk={$ndk} {event} />
{/if}