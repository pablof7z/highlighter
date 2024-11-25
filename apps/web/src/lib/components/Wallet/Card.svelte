<script lang="ts">
	import { currencyFormat } from '$utils/currency';
    import * as Card from "$components/ui/card";
	import { walletBalances, walletsBalance } from "$stores/wallet";
	import { nicelyFormattedSatNumber, pluralize } from "$utils";
	import { NDKCashuWallet, NDKWallet, NDKWalletBalance } from "@nostr-dev-kit/ndk-wallet";
	import { DotsThree, Lightning } from "phosphor-svelte";
	import Topup from "./Topup.svelte";
	import { Button } from "$components/ui/button";
    import { wallet as defaultWallet } from "$stores/wallet";

    export let wallet: NDKWallet;

    let isDefault: boolean = false;

    $: isDefault = ($defaultWallet?.walletId === wallet.walletId)

    let balances: NDKWalletBalance[] | undefined;
    wallet.on("balance_updated", () => {
        balances = wallet.balance;
    })

    balances = wallet.balance() ?? [];
</script>

<Card.Root class="w-64 bg-secondary/20 text-secondary-foreground">
    <Card.Header class="p-4 flex flex-col gap-4">
        <Card.Title class="text-muted-foreground">
            {wallet.name??"Wallet ("+wallet.type+")"}
        </Card.Title>
        <Card.Description>
            <div class="flex flex-row gap-1 text-3xl text-foreground items-center font-bold">
                {#await wallet.balance()}
                    <Lightning class="text-accent w-6 h-6" weight="fill" />
                    Loading
                {:then balances}
                    {#each balances as {amount, unit}}
                        <div class="flex flex-row items-center">
                            <Lightning class="text-accent w-6 h-6" weight="fill" />
                            {currencyFormat(unit, amount)}
                        </div>
                    {/each}
                {/await}
            </div>
        </Card.Description>

        {#if wallet instanceof NDKCashuWallet}
            <div class="flex flex-row gap-2 items-center">
                <div class="text-base w-fit bg-secondary px-4 p-2 rounded-full">
                    {wallet.mints.length} {pluralize(wallet.mints.length, "mint")}
                </div>

                <div class="flex flex-col text-base w-fit bg-secondary px-4 p-2 rounded-full">
                    <div>{wallet.relays.length} {pluralize(wallet.relays.length, "relay")}:</div>
                    <!-- <div class="flex flex-row items-center">
                        {#each wallet.relays as relay}
                            <ConnectivityIndicator url={relay} />
                        {/each}
                    </div> -->
                </div>
            </div>
        {/if}
        
    </Card.Header>
    {#if wallet instanceof NDKCashuWallet}
        <Card.Content class="p-4 md:pt-0 flex flex-row gap-4 items-stretch">
            <Topup {wallet} amount={5} class="grow" />

            <Button variant="secondary" class="w-11 rounded-full p-0" href="/wallet/settings?id={wallet.walletId}">
                <DotsThree size={24} />
            </Button>
            
        </Card.Content>
    {/if}
</Card.Root>

