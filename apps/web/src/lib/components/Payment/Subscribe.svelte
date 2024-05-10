<script lang="ts">
	import { ndk, newToasterMessage, nicelyFormattedSatNumber } from "@kind0/ui-common";
	import { onMount } from "svelte";
    import { NDKSubscriptionTier, type NDKEvent, type NDKIntervalFrequency, type NDKUser, NDKSubscriptionStart, type NDKTag } from "@nostr-dev-kit/ndk";
    import { defaultRelays } from "$lib/utils/const";
	import { termToShort } from "$utils/term";
	import { createSubscriptionEvent } from "./subscription-event";
	import { slide } from "svelte/transition";
    import { createEventDispatcher } from "svelte";
	import { currencyFormat } from "$utils/currency";
	import SubscribeStatusInfo from "./SubscribeStatusInfo.svelte";
	import { bookmarkGroup } from "$lib/nip29";
	import { groupsList } from "$stores/session";

    export let amount: string;
    export let currency: string;
    export let term: NDKIntervalFrequency;
    export let tier: NDKSubscriptionTier | undefined = undefined;

    /**
     * User that is being supported, passed in when no plan is provided
     */
    export let supportedUser: NDKUser | undefined = tier?.author;

    const dispatch = createEventDispatcher();

    let bitcoinPrice: number | undefined;
    let satsAmount: number | undefined;

    onMount(async () => {
        if (currency === 'msat') {
            satsAmount = Math.floor(Number(amount) / 1000);
        } else {
            const response = await fetch(
                "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd",
                {
                    mode: "no-cors",
                }
            );
            const data = await response.json();
            bitcoinPrice = data.bitcoin.usd;

            if (!bitcoinPrice) {
                newToasterMessage("Failed to fetch bitcoin price, try again please", "error");
                return;
            }

            satsAmount = Math.floor(Number(amount) / 100 / bitcoinPrice * 100_000_000);
        }
        // XXX HARDCODE
        // satsAmount = 10;
    });

    let subscribing = false;
    let error: string | undefined;

    async function startSubscription(subscriptionEvent: NDKSubscriptionStart) {
        const res = await fetch("/api/user/subscribe", {
            method: "POST",
            headers: { "Content-Type": "application/json", },
            body: JSON.stringify({
                subscriptionEvent: JSON.stringify(subscriptionEvent.rawEvent())
            }),
        });

        const status = res.status;

        if (status !== 200) {
            const text = await res.text();
            newToasterMessage("Failed to start subscription: " + text, "error");
            subscribing = false;

            return;
        }

        bookmarkGroup($ndk, subscribeEvent!.recipient!.pubkey!, defaultRelays, $groupsList);

        const data = await res.json();

        if (data.error) {
            subscribing = false;
            newToasterMessage(data.error, "error");
            return;
        }

        dispatch("paid", { preimage: data.preimage });
    }

    let subscribeEvent: NDKSubscriptionStart | undefined;

    async function subscribe() {
        error = undefined;
        subscribing = true;

        if (!satsAmount) {
            newToasterMessage("Invalid amount", "error");
            return;
        }

        try {
            subscribeEvent = await createSubscriptionEvent($ndk, amount, currency, term, supportedUser, tier);

            await startSubscription(subscribeEvent);
        } catch (e: any) {
            console.trace(e.message);
            error = e.message;
            subscribing = false;
            return;
        }
    }
</script>

<div class="text-lg font-medium flex flex-col items-center gap-1">
    {#if currency !== 'msat'}
        <div class="text-4xl text-white font-bold">
            {currencyFormat(currency, parseInt(amount))}/{termToShort(term)}
        </div>

        {#if satsAmount}
            <div class="opacity-60 font-normal">({nicelyFormattedSatNumber(satsAmount)} sats)</div>
        {/if}
    {:else}
        {currencyFormat(currency, parseInt(amount))}
    {/if}
</div>

<div class="min-w-[300px] flex-col justify-start items-center gap-3 inline-flex">
    {#if error}
        <div class="alert alert-error" transition:slide>
            {error}
        </div>
    {/if}

    {#if subscribeEvent && subscribing}
        <SubscribeStatusInfo {subscribeEvent} />
    {/if}

    <button class="button w-full" on:click={subscribe} disabled={subscribing}>
        {#if subscribing}
            <div class="loading loading-sm"></div>
        {:else}
            Subscribe
        {/if}
    </button>

    <div class="flex flex-col gap-2 items-center">
        <div class="text-neutral-400 text-sm font-medium leading-[19px]">Connected with NWC</div>
        <button class="text-xs text-neutral-500" on:click={() => dispatch('disconnectWallet')}>Disconnect NWC</button>
    </div>

</div>