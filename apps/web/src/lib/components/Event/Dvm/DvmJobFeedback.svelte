<script lang="ts">
	import LnQrCode from "$components/Payment/LnQrCode.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import DvmInput from "./DvmInput.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";

    export let event: NDKEvent;

    const isPaymentRequired = event.tagValue('status') === "payment-required"
    const [ _, amount, pr ] = event.getMatchingTags("amount")?.[0] || []

    
</script>

{#each event.getMatchingTags("i") as inputTag}
    <DvmInput {inputTag} />
{/each}

{#if isPaymentRequired && pr}
    <LnQrCode {pr} satAmount={parseInt(amount)/1000} tryToPay={false} />
    <p>Payment required</p>
{/if}

<EventContent ndk={$ndk} {event} />