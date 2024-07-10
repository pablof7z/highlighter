<script lang="ts">
	import { Button } from "$components/ui/button";
	import LnQrModal from "$modals/LnQrModal.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKCashuToken } from "$utils/cashu/token";
	import { NDKCashuWallet } from "$utils/cashu/wallet";
	import { CashuMint, CashuWallet } from "@cashu/cashu-ts";
	import { openModal, closeModal } from "$utils/modal";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
	import { NDKRelaySet } from "@nostr-dev-kit/ndk";

    export let walletEvent: NDKCashuWallet;
    export let amount = 10;

    let relaySet: NDKRelaySet;
    if (walletEvent?.relays?.length > 0) {
        relaySet = NDKRelaySet.fromRelayUrls(walletEvent.relays, $ndk);
        console.log({relaySet: relaySet.relayUrls})
    } else {
        console.error("No relays found for wallet event", walletEvent.rawEvent());
    }

    let open = false;

    function longpress() {

    }

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

    async function topUp(mint?: string) {
        mint ??= mints[0];
        const wallet = new CashuWallet(new CashuMint(mint));
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
                tokenEvent.mint = mint;
                if (walletEvent)
                    tokenEvent.wallet = walletEvent;
                console.log('token', tokenEvent.rawEvent());
                const res = await tokenEvent.publish(relaySet);
                console.log('published', res);
                closeModal();
            }
        }, 1500);
    }

    const mints = Array.from(
        new Set(walletEvent.getMatchingTags("mint").map(t => t[1]))
    );
</script>

<DropdownMenu.Root bind:open>
    <DropdownMenu.Trigger class="w-full flex">
        <Button class="w-full" {...$$props} longpress={50} on:longpress={longpress}>Top Up</Button>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content>
        <DropdownMenu.Group>
            {#each mints as mint}
                <DropdownMenu.Item on:click={() => topUp(mint)}>
                    {mint}
                </DropdownMenu.Item>
            {/each}
        </DropdownMenu.Group>
    </DropdownMenu.Content>
</DropdownMenu.Root>
<!-- <Button size="sm" class="w-full" {...$$props} on:click={topUp} longpress={true} on:longpress={longpress}>Top Up</Button> -->