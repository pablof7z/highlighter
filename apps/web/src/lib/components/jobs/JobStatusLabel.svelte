<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import PaymentRequiredButton from "./PaymentRequiredButton.svelte";

    export let event: NDKEvent | undefined = undefined;
    export let status: string | undefined = undefined;

    if (!status && event) status = event.tagValue("status");
</script>

{#if status === 'success'}
    <span class="text-success">Success</span>
{:else if status === 'processing'}
    <span class="text-info">Processing</span>
{:else if status === 'payment-required' && event}
    <PaymentRequiredButton {event} />
{:else}
    {status}
{/if}