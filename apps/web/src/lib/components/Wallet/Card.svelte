<script lang="ts">
	import ConnectivityIndicator from "$components/Relay/ConnectivityIndicator.svelte";
    import * as Card from "$components/ui/card";
	import { walletsBalance } from "$stores/wallet";
	import { nicelyFormattedSatNumber, pluralize } from "$utils";
	import { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
	import { DotsThree, Lightning } from "phosphor-svelte";
	import Topup from "./Topup.svelte";
	import { Button } from "$components/ui/button";

    export let wallet: NDKCashuWallet;

    let balance: number | undefined;

    $: balance = $walletsBalance.get(wallet.walletId);
</script>

<Card.Root class="w-64 bg-secondary/20 text-secondary-foreground">
    <Card.Header class="p-4 flex flex-col gap-4">
        <Card.Title class="text-muted-foreground">{wallet.name}</Card.Title>
        <Card.Description>
            {#if balance}
                <div class="flex flex-row gap-1 text-3xl text-foreground items-center font-bold">
                    <Lightning class="text-accent w-6 h-6" weight="fill" />
                    {nicelyFormattedSatNumber(balance)} sats
                </div>
            {/if}
        </Card.Description>

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
        
    </Card.Header>
    <Card.Content class="p-4 md:pt-0 flex flex-row gap-4 items-stretch">
        <Topup walletEvent={wallet} amount={5} class="grow" />

        <Button variant="secondary" class="w-11 rounded-full p-0" href="/wallet/settings?id={wallet.walletId}">
            <DotsThree size={24} />
        </Button>
        
    </Card.Content>
</Card.Root>