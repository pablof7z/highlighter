<script lang="ts">
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { NDKEvent, zapInvoiceFromEvent } from "@nostr-dev-kit/ndk";
	import { Lightning } from 'phosphor-svelte';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import { ndk } from '$stores/ndk';
	import { nicelyFormattedMilliSatNumber } from '$utils';

    export let zapEvent: NDKEvent;
    const zapReceipt = zapInvoiceFromEvent(zapEvent);

    const zappee = zapReceipt?.zappee;
    const zapAmount = zapReceipt?.amount;
    const zapped = zapReceipt?.zapped;
    const eventId = zapReceipt?.zappedEvent;

    let event: NDKEvent | null;
    if (eventId) {
        $ndk.fetchEvent(eventId).then((e) => {
            event = e;
        });
    }
</script>

{#if zappee && zapAmount && zapped && zapAmount > 0 && event}
    <div class="flex flex-row items-center w-full gap-2 justify-between discussion-item !border rounded-t-box !border-yellow-300 px-4 py-2">
        <div class="grow">
            <AvatarWithName pubkey={zappee} avatarSize="small" nameClass="text-sm" />
        </div>

        <div class="text-yellow-300 text-center font-semibold text-sm whitespace-nowrap">
            <Lightning class="w-6 h-6 inline-block" />
            {nicelyFormattedMilliSatNumber(zapAmount)}
        </div>
    </div>
    <EventWrapper {event} />
{/if}