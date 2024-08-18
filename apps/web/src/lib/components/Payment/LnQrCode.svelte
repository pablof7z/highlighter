<script lang="ts">
	import CopyButton from "$components/buttons/CopyButton.svelte";
	import { Button } from "$components/ui/button";
	import { nicelyFormattedSatNumber } from "$utils";
	import { Check } from "phosphor-svelte";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
    import QRCode from "@bonosoft/sveltekit-qrcode"
	import { requestProvider } from "webln";
	import { NDKFilter, NDKSubscription } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";

    export let pr: string;
    export let satAmount: number;
    export let zapWatcherFilter: NDKFilter | undefined = undefined;
    export let paid = false;
    export let size = 350;
    export let tryToPay = true;
    let provider: any;

    const dispatcher = createEventDispatcher();

    onMount(() => {
        try {
            requestProvider().then(async (p) => {
                provider = p;
                // if (tryToPay) pay();
            });
        } catch {}

        if (zapWatcherFilter) {
            zapWatcherSub = $ndk.subscribe(zapWatcherFilter);
            zapWatcherSub.on("event", (e) => {
                dispatcher("paid", e);
                paid = true;
            });
        }
    });

    let zapWatcherSub: NDKSubscription;

    onDestroy(() => {
        zapWatcherSub?.stop();
    })

    async function pay() {
        if (!provider) {
            window.open("lightning:" + pr, "_blank");
            return;
        }
        
        try {
            const res = await provider.sendPayment(pr);

            if (res?.paid) {
                dispatcher("paid", res);
            }
        } catch (e) {
            console.error(e);
            provider = null
        }
    }
</script>

{#if !paid}
    <div class="flex flex-col gap-2 justify-stretch items-center w-full">
        <QRCode content={`lightning:${pr}`} color="#444444" size={size.toString()} />
        <div class="w-full">
            <CopyButton data={pr} class="!text-sm !text-muted-foreground !font-light truncate !font-mono w-full m-1" />
        </div>

        <Button class="w-full" on:click={pay}>
            Pay
            {#if satAmount}
                {nicelyFormattedSatNumber(satAmount)}
                sats
            {/if}
        </Button>
    </div>
{:else}
    <Check class="text-green-500 w-48 h-48" />
{/if}
