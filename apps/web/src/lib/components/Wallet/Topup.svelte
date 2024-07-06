<script lang="ts">
	import { Button } from "$components/ui/button";
	import LnQrModal from "$modals/LnQrModal.svelte";
	import { walletRelaySet } from "$stores/cashu";
	import { ndk } from "$stores/ndk";
	import { NDKCashuToken } from "$utils/cashu/token";
	import { NDKCashuWallet } from "$utils/cashu/wallet";
	import { CashuMint, CashuWallet } from "@cashu/cashu-ts";
	import { openModal, closeModal } from "svelte-modals";

    export let walletEvent: NDKCashuWallet;
    export let amount = 10;
    export let mint = walletEvent?.tagValue("mint")! ?? "https://stablenut.umint.cash";

    const wallet = new CashuWallet(new CashuMint(mint));

    function amountToPreference(n) {
        const powers = [];
        let i = 0;
        while (n > 0) {
            if (n % 2 === 1) {
                powers.push(2 ** i);
            }
            n = Math.floor(n / 2);
            i++;
        }
        return powers.map((p) => ({ amount: p, count: 1 }));
    }

    async function topUp() {
        const quote = await wallet.mintQuote(amount);
        console.log({quote})

        openModal(LnQrModal, { pr: quote.request, satAmount: amount, title: "Top up wallet" });
        
        const checkPaidInterval = setInterval(async () => {
            const ret = await wallet.mintTokens(amount, quote.quote, {
                preference: amountToPreference(amount),
            });

            if (ret.proofs) {
                clearInterval(checkPaidInterval);
                const tokenEvent = new NDKCashuToken($ndk);
                tokenEvent.proofs = ret.proofs;
                if (walletEvent)
                    tokenEvent.wallet = walletEvent;
                await tokenEvent.sign();
                console.log('token', tokenEvent.rawEvent());
                tokenEvent.publish(walletRelaySet);
                closeModal();

                walletEvent.addToken(tokenEvent);
            }
        }, 1500);
    }
</script>

<Button size="sm" class="w-full" {...$$props} on:click={topUp}>Top Up</Button>