<script lang="ts">
	import { Button } from "$components/ui/button";
	import LnQrModal from "$modals/LnQrModal.svelte";
	import { ndk } from "$stores/ndk";
	import { CashuMint, CashuWallet } from "@cashu/cashu-ts";
	import { openModal, closeModal } from "$utils/modal";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
	import { NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { CaretDown } from "phosphor-svelte";
	import { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
	import { toast } from "svelte-sonner";
	import LnQrCode from "$components/Payment/LnQrCode.svelte";

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

    async function topUp(mint?: string) {
        const deposit = walletEvent.deposit(amount, mint);
        console.log("deposit", deposit);
        deposit.on("success", () => {
            toast("Deposit success");
            closeModal(LnQrModal);
        });
        const pr = await deposit.start();

        openModal(LnQrModal, { pr, satAmount: amount, title: "Top up wallet" });
        
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