<script lang="ts">
	import { ndk, nicelyFormattedSatNumber } from "@kind0/ui-common";
	import { onMount } from "svelte";
    import { webln } from "@getalby/sdk";
	import { NDKEvent, type NostrEvent } from "@nostr-dev-kit/ndk";
	import type { Term } from "$utils/term";

    export let amount: string;
    export let currency: string;
    export let nwcUrl: string;
    export let term: Term;
    export let plan: NDKEvent;

    let bitcoinPrice: number | undefined;
    const nwc = new webln.NWC({ nostrWalletConnectUrl: nwcUrl });

    onMount(async () => {
        const response = await fetch("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
        const data = await response.json();
        bitcoinPrice = data.bitcoin.usd;
    });

    let subscribing = true;

    async function subscribe() {
        const supportEvent = new NDKEvent($ndk, {
            kind: 7001,
            tags: [
                [ "amount", amount, currency, term ],
                [ "event", JSON.stringify(plan.rawEvent()) ],
            ]
        } as NostrEvent);
        supportEvent.tag(plan);

        await supportEvent.sign();

        console.log(supportEvent.rawEvent());
    }
</script>

<div class="text-black text-sm font-medium leading-[19px]">
    ${amount}
    {#if bitcoinPrice}
        ({nicelyFormattedSatNumber(Math.floor(Number(amount) / bitcoinPrice * 100_000_000))} sats)
    {/if}
</div>

<div class="w-[300px] h-[75px] flex-col justify-start items-center gap-3 inline-flex">
    {#await nwc.enable()}
        <div class="loading loading-sm"></div>
    {:then}
        <button class="button button-primary w-full" on:click={subscribe}>
            Subscribe
        </button>
    {:catch e}
        <div class="text-red-500 text-sm font-medium leading-[19px]">
            {e.message}
        </div>
    {/await}

    <div class="text-neutral-400 text-sm font-medium leading-[19px]">Connected with NWC</div>
</div>