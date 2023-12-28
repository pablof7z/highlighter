<script lang="ts">
	import { ndk, newToasterMessage, nicelyFormattedSatNumber } from "@kind0/ui-common";
	import { onMount } from "svelte";
    import type { NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
	import type { Term } from "$utils/term";
	import { createSubscriptionEvent, createZapRequest } from "./subscription-event";
	import { slide } from "svelte/transition";
    import { createEventDispatcher } from "svelte";
	import { currencyFormat } from "$utils/currency";

    export let amount: string;
    export let currency: string;
    export let term: Term;
    export let plan: NDKEvent | undefined = undefined;

    /**
     * User that is being supported, passed in when no plan is provided
     */
    export let supportedUser: NDKUser | undefined = plan?.author;

    const dispatch = createEventDispatcher();

    const zapComment = "Getfaaans.com supporter";

    let bitcoinPrice: number | undefined;
    let satsAmount: number | undefined;

    onMount(async () => {
        const response = await fetch("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
        const data = await response.json();
        bitcoinPrice = data.bitcoin.usd;

        if (!bitcoinPrice) {
            newToasterMessage("Failed to fetch bitcoin price, try again please", "error");
            return;
        }

        satsAmount = Math.floor(Number(amount) / bitcoinPrice * 100_000_000);
        // XXX HARDCODE
        // satsAmount = 10;
    });

    let subscribing = false;
    let error: string | undefined;

    async function sendZap(zapRequest: NDKEvent) {
        const res = await fetch("/api/user/pay-zap-request", {
            method: "POST",
            headers: { "Content-Type": "application/json", },
            body: JSON.stringify({
                zapRequest: JSON.stringify(zapRequest.rawEvent())
            }),
        });

        const data = await res.json();
        const stutus = res.status;

        if (data.error) {
            newToasterMessage(data.error, "error");
            return;
        }

        dispatch("paid", { preimage: data.preimage });
    }

    async function subscribe() {
        error = undefined;
        subscribing = true;

        if (!satsAmount) {
            newToasterMessage("Invalid amount", "error");
            return;
        }

        try {
            const supportEvent = await createSubscriptionEvent($ndk, amount, currency, term, plan, supportedUser);
            const zapRequest = await createZapRequest(supportEvent, zapComment);
            console.log('zaprequest id', zapRequest.id, zapRequest.rawEvent());
            zapRequest.sig = await $ndk.signer?.sign(zapRequest.rawEvent());
            console.log('after signing zaprequest id', zapRequest.id, zapRequest.rawEvent());
            await sendZap(zapRequest);
            await supportEvent.publish();
        } catch (e: any) {
            console.trace(e.message);
            error = e.message;
            subscribing = false;
            return;
        }
        // const invoice = await supportEvent.zap(satsAmount*1000, zapComment, undefined, supportedUser);

        // if (!invoice) {
        //     newToasterMessage("Failed to fetch an invoice, try again please", "error");
        //     return;
        // }

        // try {
        //     preimage = await nwcPay(invoice);
        //     dispatch("paid", { preimage });
        // } catch (e: any) {
        //     error = e.message;
        //     subscribing = false;
        //     return;
        // }
    }
</script>

<div class="text-black text-sm font-medium leading-[19px]">
    {#if currency !== 'msat'}
        {currencyFormat(currency, amount)}
        {#if satsAmount}
            ({nicelyFormattedSatNumber(satsAmount)} sats)
        {/if}
    {:else}
        {currencyFormat(currency, amount)}
    {/if}
</div>

<div class="min-w-[300px] flex-col justify-start items-center gap-3 inline-flex">
    {#if error}
        <div class="alert alert-error" transition:slide>
            {error}
        </div>
    {/if}

    <button class="button button-primary w-full" on:click={subscribe} disabled={subscribing}>
        {#if subscribing}
            <div class="loading loading-sm"></div>
        {:else}
            Subscribe
        {/if}
    </button>

    <div class="text-neutral-400 text-sm font-medium leading-[19px]">Connected with NWC</div>
</div>