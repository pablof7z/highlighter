<script lang="ts">
	import { ndk } from "$stores/ndk.js";
    import { NDKSubscriptionTier, type NDKSubscriptionStart, NDKIntervalFrequency } from "@nostr-dev-kit/ndk";
	import { createSubscriptionEvent } from "./subscription-event";
	import { onMount } from "svelte";

    export let pubkey: string;
    export let term: NDKIntervalFrequency;
    export let amount: number;
    export let currency: string;
    export let tier: NDKSubscriptionTier;

    onMount(redirect);

    let connecting = false;

    async function redirect() {
        connecting = true;
        try {
            const supportedUser = $ndk.getUser({pubkey})
            let subscribeEvent: NDKSubscriptionStart | undefined;

            try {
                subscribeEvent = await createSubscriptionEvent($ndk, amount.toString(), currency, term, supportedUser, tier);
            } catch {}

            const response = await fetch(`/api/stripe`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    pubkey,
                    term,
                    amount,
                    currency,
                    tierId: tier.encode(),
                    event: JSON.stringify(subscribeEvent?.rawEvent())
                })
            });

            const { url } = await response.json();
            if (url) window.location.href = url;
        } finally {
            connecting = false;
        }
    }
</script>



<button class="button px-8" on:click={redirect} disabled={connecting}>
    {#if connecting}
        Redirecting to Stripe
        <span class="loading"></span>
    {:else}
        Continue on Stripe
    {/if}
</button>