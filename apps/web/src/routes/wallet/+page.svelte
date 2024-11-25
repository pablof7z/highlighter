<script lang="ts">
	import { page } from "$app/stores";
	import { Button } from "$components/ui/button";
    import * as Alert from "$lib/components/ui/alert";
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
	import { wallets, wallet } from "$stores/wallet";
	import { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
	import { NDKCashuMintList, NDKEvent, NDKKind, NDKList, NostrEvent } from "@nostr-dev-kit/ndk";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { activeWallet } from "$stores/settings";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";

    $layout.title = "Wallet";
    $layout.back = {url: "/"};
    
    onMount(() => {
        addHistory({ title: "Wallet", url: $page.url.toString() });
    })

    async function create() {
        const wallet = await createNewWallet();
        goto(`/wallet/settings?id=${wallet.dTag}`);
    }

    let mintList: NDKEventStore<NDKEvent> | undefined;

    $: if ($currentUser && !mintList) {
        mintList = $ndk.storeSubscribe({ kinds: [NDKKind.CashuMintList], authors: [$currentUser?.pubkey!]})
    }

    async function addMintList() {
        const mintList = new NDKCashuMintList($ndk);

        const cashuWallet = $wallet as NDKCashuWallet;
        mintList.mints = cashuWallet.mints;
        mintList.relays = cashuWallet.relays;
        mintList.p2pk = cashuWallet.p2pk;
        await mintList.publish();
    }
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

{#if $wallet &&$activeWallet?.type === 'nip-60' && $mintList?.length === 0}
    <Alert.Root>
        <Alert.Title>Heads up!</Alert.Title>
        <Alert.Description class="flex flex-row w-full justify-between items-center">
            You are not setup to receive payments yet!
            <Button on:click={addMintList}>
                Fix
            </Button>
        </Alert.Description>
        
    </Alert.Root>
{/if}

{#if $wallet}
    <WalletCard wallet={$wallet} />
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