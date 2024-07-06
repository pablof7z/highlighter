<script lang="ts">
	import { Button } from "$components/ui/button";
	import * as Card from "$components/ui/card";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import Topup from "$components/Wallet/Topup.svelte";
	import LnQrModal from "$modals/LnQrModal.svelte";
	import { activeWalletEvent, walletBalance, walletEvents, walletRelaySet } from "$stores/cashu";
    import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { nicelyFormattedSatNumber } from "$utils";
	import { NDKCashuToken } from "$utils/cashu/token";
	import { NDKCashuWallet } from "$utils/cashu/wallet";
	import { closeModal, openModal } from "$utils/modal";
	import { CashuWallet, CashuMint } from "@cashu/cashu-ts";
	import { Block } from "konsta/svelte";
	import { Lightning } from "phosphor-svelte";

    let mint: string = "https://stablenut.umint.cash";
    let wallet: CashuWallet;

    $: if (!wallet && $activeWalletEvent?.mint) {
        wallet = new CashuWallet(new CashuMint($activeWalletEvent.mint));
    }

    let walletEvent: NDKCashuWallet;

    async function createWallet() {
        const w = new CashuWallet(new CashuMint(mint));
        
        if ($activeWalletEvent) {
            walletEvent = NDKCashuWallet.from($activeWalletEvent);
        } else {
            walletEvent = new NDKCashuWallet($ndk);
            walletEvent.dTag = "dhckj6m5qny3iuwg";
            walletEvent.mint = mint;
        }
        walletEvent.relays = walletRelaySet.relayUrls;

        try {
            const p = await walletEvent.publishReplaceable(walletRelaySet);
        } catch (e) {
            console.error('error publishing wallet', e?.relayErrors);
            return;
        }

        wallet = w;

        // const walletKeyEvent = new NDKCashuWalletKey($ndk);
        // walletKeyEvent.keys = w.keys;
        // walletKeyEvent.wallet = walletEvent;
        // await walletKeyEvent.publish(relaySet);
    }
</script>

<Block class="flex flex-col gap-8">
    <ScrollArea orientation="horizontal">
        <div class="flex flex-row gap-8 flex-nowrap w-max pb-8">
            {$walletEvents.length}
            {#each $walletEvents as wallet}
                <Card.Root class="w-64 bg-secondary text-secondary-foreground">
                    <Card.Header class="p-4 flex flex-col gap-4">
                        <Card.Title class="text-muted-foreground">{wallet.dTag}</Card.Title>
                        {wallet.tagValue("mint")}
                        <Card.Description>
                            <div class="flex flex-row gap-1 text-3xl text-foreground items-center font-bold">
                                <Lightning class="text-accent w-6 h-6" weight="fill" />
                                {nicelyFormattedSatNumber($walletBalance)} sats
                            </div>
                        </Card.Description>
                    </Card.Header>
                    <Card.Content class="p-4 md:pt-0">
                        <Topup {walletEvent} amount={20} />
                    </Card.Content>
                </Card.Root>
            {/each}

            <Card.Root class="w-64 bg-secondary">
                <Card.Header class="p-4">
                    <Card.Title>Create New</Card.Title>
                    <Card.Description>
                        Unlock all features and get unlimited access to our support team.
                    </Card.Description>
                </Card.Header>
                <Card.Content class="p-4 md:pt-0">
                </Card.Content>
            </Card.Root>
        </div>
    </ScrollArea>
</Block>

{#if $walletBalance}
    balance: {walletBalance}
{:else}
    <Button size="lg" on:click={createWallet}>
        Create Wallet
    </Button>
{/if}