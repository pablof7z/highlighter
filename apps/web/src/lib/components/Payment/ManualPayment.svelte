<script lang="ts">
	import { calculateSatAmountFromAmountTag, currencyFormat } from "$utils/currency";
    import UserProfile from "$components/User/UserProfile.svelte";
	import { NDKEvent, NDKSubscription, NDKUser, NDKZap } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { creatorRelayPubkey } from "$utils/const";
	import { Check } from "phosphor-svelte";
	import Box from "$components/PageElements/Box.svelte";
	import { nicelyFormattedSatNumber } from "$utils";
	import { ndk } from "$stores/ndk";
	import LnQrCode from "./LnQrCode.svelte";
	import currentUser from "$stores/currentUser";

    export let event: NDKEvent;
    export let recipient: NDKUser;

    const events = $ndk.storeSubscribe([
        { kinds: [7003, 9735], ...event.filter() },
        { kinds: [7003], ...event.filter(), authors: [creatorRelayPubkey]}
    ])

    let receivedZap = false;
    let subscriptionReceiptGenerated = false;

    $: receivedZap = $events.some((e) => e.kind === 9735);
    $: subscriptionReceiptGenerated = $events.some((e) => e.kind === 7003);

    let provider: any;
    let pr: string | null;
    let satAmount: number;
    let amount: string;
    let currency: string;

    const dispatch = createEventDispatcher();

    $: if (subscriptionReceiptGenerated) {
        setTimeout(() => {
            dispatch('paid');
        }, 1000);
    }

    const amountTag = event.getMatchingTags('amount')[0];
	if (!amountTag) throw new Error('Amount not found');
    amount = amountTag[1];
	currency = amountTag[2];
    calculateSatAmountFromAmountTag(amountTag).then(async (amount) => {
        const zap = new NDKZap({
            ndk: $ndk,
            zappedEvent: event,
            zappedUser: recipient
        });
        satAmount = amount;

        amount = 10;

        // ping the backend, this should be unnecessary but might as well
        fetch("/api/subscriptions/validate", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                event: event.encode()
            })
        });

        event.publish();

        pr = await zap.createZapRequest(
            satAmount * 1000,
            "Highlighter subscriber"
        );

        zapWatcher = $ndk.subscribe({
            "kinds": [9735],
            "#p": [ recipient.pubkey ],
            "#P": [ $currentUser.pubkey ],
            limit: 0
        }, { subId: 'zap-watcher', groupable: false })
        zapWatcher.on("event", (e: NDKEvent) => {
            receivedZap = true;
        });
    });

    let zapWatcher: NDKSubscription;

    onDestroy(() => {
        zapWatcher?.stop();
    });
</script>

<UserProfile user={recipient} let:userProfile>
    {#if userProfile?.lud16}
        <div class="text-center -translate-y-5 text-sm font-light">
            {userProfile.lud16}
        </div>
    {/if}
</UserProfile>

<div class="
    flex items-start gap-6
    flex-col-reverse
">
    {#if pr}
        <div class="flex flex-col items-center gap-4">
            <div class="text-4xl text-foreground font-bold">
                {currencyFormat(currency, parseInt(amount))}
            </div>

            {#if currency !== 'msat'}
                <div class="opacity-60 font-normal">({nicelyFormattedSatNumber(satAmount)} sats)</div>
            {/if}

            <LnQrCode {pr} {satAmount} />

            <div class="flex flex-col w-full">
                <div class="flex flex-row gap-2">
                    {#if !receivedZap}
                        <span class="loading loading-sm" />
                        Waiting for payment
                    {:else}
                        <Check class="w-5 h-5 text-green-500" />
                        Payment received
                    {/if}
                </div>

                <div class="flex flex-row gap-2">
                    {#if !subscriptionReceiptGenerated}
                        <span class="loading loading-sm" />
                        Waiting for subscription receipt
                    {:else}
                        <Check class="w-5 h-5 text-green-500" />
                        Subscription receipt received
                    {/if}
                </div>
            </div>
        </div>
    {:else}
        <Box class="min-h-[300px] flex-col items-center justify-center">
            <span class="loading loading-lg" />
            Generating invoice, one sec.
        </Box>
    {/if}

    <!-- <StylishContainer class="p-4 max-w-[45ch]" border={1}>
        <div class="text-foreground font-semibold">
            This is a one-off payment
        </div>

        <p>
            Supporting the work you want to see in the world is the most effective way
            to make sure it flourishes and continues to happen.
        </p>
    </StylishContainer> -->
</div>