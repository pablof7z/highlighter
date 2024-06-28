<script lang="ts">
	import Avatar from "$components/User/Avatar.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { nicelyFormattedMilliSatNumber } from "$utils";
import { NDKEvent, zapInvoiceFromEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;

    const invoice = zapInvoiceFromEvent(event);
</script>

{#if invoice}
    <div class="flex flex-row items-center justify-between">
        <div class="flex flex-col items-center justify-center">
            <AvatarWithName pubkey={invoice.zappee} />
        </div>

        <div class="flex flex-col items-center justify-center">
            <h1>
                {nicelyFormattedMilliSatNumber(invoice.amount)}
                sats
            </h1>
        </div>
    </div>

    <blockquote>
        {invoice.comment}
    </blockquote>
{/if}