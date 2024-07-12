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
	import { CaretDown } from "phosphor-svelte";

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

    // create a function that grabs the amount and creates combinations that sum to the amount,
    // starting with 1, then 2, then 3, then 4, etc -- it should set the count to the number of
    // times that amount is used in the combination instead of repeating the amount in the array
    function amountToPreference(amount: number) {
        const preferences: { amount: number, count: number }[] = [];
        let remainder = amount;

        preferences.push({ amount: 2, count: remainder / 2 });
        remainder = remainder % 2;
        if (remainder > 0)
            preferences.push({ amount: 1, count: remainder });

        return preferences;
    }


    async function topUp(mint?: string) {
        mint ??= mints[0];
        const wallet = new CashuWallet(new CashuMint(mint));
        const quote = await wallet.mintQuote(amount);

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

    function topUpFromAnyMint() {
        const randomMint = mints[Math.floor(Math.random() * mints.length)];
        topUp(randomMint);
    }
</script>

<DropdownMenu.Root bind:open>
    <Button class="w-full !rounded-r-0 flex flex-row items-center !px-0" {...$$props} on:click={topUpFromAnyMint}>
        <div class="flex-grow">Top Up</div>
        <DropdownMenu.Trigger class="flex bg-black/10 p-4 translate-x-4">
            <button class="w-fit" {...$$props}>
                <CaretDown />
            </button>
        </DropdownMenu.Trigger>
    </Button>
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