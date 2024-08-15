<script lang="ts">
	import { page } from "$app/stores";
	import { Button } from "$components/ui/button";
	import * as Card from "$components/ui/card";
	import { addHistory } from "$stores/history";
    import { layout } from "$stores/layout";
	import { Coin, DotsThree, Lightning, PlusCircle } from "phosphor-svelte";
	import { onMount } from "svelte";
    import HorizontalList from "$components/PageElements/HorizontalList/List.svelte";
	import { derived, Readable } from "svelte/store";
    import WalletCard from "$components/Wallet/Card.svelte";

    import { createNewWallet } from "$lib/actions/wallet/new.js";
	import { goto } from "$app/navigation";
	import { ndk } from "$stores/ndk";
	import { zap } from "$utils/zap";
	import { wallets, walletBalance, walletsBalance } from "$stores/wallet";

    $layout.title = "Wallet";
    $layout.back = {url: "/"};
    
    onMount(() => {
        addHistory({ title: "Wallet", url: $page.url.toString() });
    })

    async function create() {
        const wallet = await createNewWallet();
        goto(`/wallet/settings?id=${wallet.dTag}`);
    }

    async function send() {
        const pablo = $ndk.getUser({npub: "npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft"});
        zap(1, pablo, "test")
        // const pr = await $ndk.zap(pablo, 1000, "nut zap");
        // if (!pr) {
        //     console.error("Failed to create proof request");
        //     return;
        // }
        // const ret = await payWithProofs(pr, 1000, undefined, pablo);
    }

    $: console.log ('wallets from $wallets', $wallets.map(w => w.balance))
</script>


<!-- <div class="flex flex-row max-sm:justify-evenly gap-4">
    <Button class="max-sm:w-2/5" on:click={send}>
        <Coin size={24} class="mr-2" />
        Send
    </Button>

    <Button class="max-sm:w-2/5" on:click={send}>
        <Coin size={24} class="mr-2" />
        Receive
    </Button>
</div> -->

{#if $wallets.length > 0}
    <HorizontalList idField="walletId" title="Wallets" items={$wallets} let:item={wallet}>
        {#if wallet}
            <WalletCard {wallet} />
        {/if}
    </HorizontalList>
{:else}
    <Card.Root class="w-64 bg-secondary/20 text-secondary-foreground">
        <Card.Header class="p-4 flex flex-col gap-4">
            <Card.Title class="text-muted-foreground">Wallet</Card.Title>
            <Card.Description>
                <div class="flex flex-row gap-1 text-3xl text-foreground items-center font-bold">
                    <Lightning class="text-accent w-6 h-6" weight="fill" />
                    0 sats
                </div>
            </Card.Description>

            <div class="flex flex-row gap-2 items-center">
                <div class="text-base w-fit bg-secondary px-4 p-2 rounded-full">
                </div>

                <div class="flex flex-col text-base w-fit bg-secondary px-4 p-2 rounded-full">
                </div>
            </div>
            
        </Card.Header>
        <Card.Content class="p-4 md:pt-0 flex flex-row gap-4 items-stretch">
            <Button class="w-full" on:click={create}>
                Create Wallet
            </Button>
        </Card.Content>
    </Card.Root>
{/if}