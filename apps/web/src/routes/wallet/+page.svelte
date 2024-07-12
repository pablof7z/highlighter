<script lang="ts">
	import { page } from "$app/stores";
	import { Button } from "$components/ui/button";
	import * as Card from "$components/ui/card";
	import Topup from "$components/Wallet/Topup.svelte";
	import NewWalletModal from "$modals/Wallet/NewWalletModal.svelte";
	import { walletBalance, wallets } from "$stores/cashu";
	import { addHistory } from "$stores/history";
    import { layout } from "$stores/layout";
	import { nicelyFormattedSatNumber, pluralize } from "$utils";
	import { NDKCashuWallet } from "$utils/cashu/wallet";
	import { openModal } from "$utils/modal";
	import { DotsThree, Lightning, PlusCircle } from "phosphor-svelte";
	import { onMount } from "svelte";
    import HorizontalList from "$components/PageElements/HorizontalList/List.svelte";
	import { derived, Readable } from "svelte/store";
	import ConnectivityIndicator from "$components/Relay/ConnectivityIndicator.svelte";

    $layout.title = "Wallet";
    $layout.back = {url: "/"};
    
    onMount(() => {
        addHistory({ title: "Wallet", url: $page.url.toString() });
    })

    let walletsWithAdd = derived(wallets, ($wallets) => {
        if (!$wallets || !$wallets.length) return [ { id: "add" } ];
        return [
            ...$wallets,
            { id: "add" }
        ]
    });
</script>

<HorizontalList title="Wallets" items={$walletsWithAdd} let:item={wallet}>
    {#if wallet instanceof NDKCashuWallet}
        <Card.Root class="w-64 bg-secondary/20 text-secondary-foreground">
            <Card.Header class="p-4 flex flex-col gap-4">
                <Card.Title class="text-muted-foreground">{wallet.name}</Card.Title>
                <Card.Description>
                    <div class="flex flex-row gap-1 text-3xl text-foreground items-center font-bold">
                        <Lightning class="text-accent w-6 h-6" weight="fill" />
                        {nicelyFormattedSatNumber($walletBalance.get(wallet.dTag))} sats
                    </div>
                </Card.Description>

                <div class="flex flex-row gap-2 items-center">
                    <div class="text-base w-fit bg-secondary px-4 p-2 rounded-full">
                        {wallet.mints.length} {pluralize(wallet.mints.length, "mint")}
                    </div>

                    <div class="flex flex-col text-base w-fit bg-secondary px-4 p-2 rounded-full">
                        <div>{wallet.relays.length} {pluralize(wallet.relays.length, "relay")}:</div>
                        <div class="flex flex-row items-center">
                            {#each wallet.relays as relay}
                                <ConnectivityIndicator url={relay} />
                            {/each}
                        </div>
                    </div>
                </div>
                
            </Card.Header>
            <Card.Content class="p-4 md:pt-0 flex flex-row gap-4 items-stretch">
                <Topup walletEvent={wallet} amount={48} class="grow" />

                <Button variant="secondary" class="w-11 rounded-full p-0" href="/wallet/settings?id={wallet.encode()}">
                    <DotsThree size={24} />
                </Button>
                
            </Card.Content>
        </Card.Root>
    {:else}
        <button
            class="bg-secondary w-48 min-h-[12rem] h-full rounded flex flex-row items-center justify-center text-muted-foreground"
            on:click={() => openModal(NewWalletModal)}
        >
            <PlusCircle size={64} weight="light" class="opacity-50" />
        </button>
    {/if}
</HorizontalList>