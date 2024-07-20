<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { Input } from "$components/ui/input";
	import RecommendedMintList from "$components/Wallet/RecommendedMintList.svelte";
	import { NavigationOption } from "../../../app";
    import * as Collapsible from "$lib/components/ui/collapsible";
	import { ndk } from "$stores/ndk";
	import { Button } from "$components/ui/button";
	import { closeModal } from "$utils/modal";
	import { walletService } from "$stores/wallet";

    export let name: string = "My Wallet";
    export let mint: string = "";

    let actionButtons: NavigationOption[] = [];
    let showRecommendations = false;

    function selectedMint(event: CustomEvent) {
        mint = event.detail.url;
        showRecommendations = false;
    }

    async function create() {
        const walletEvent = $walletService.createCashuWallet();
        walletEvent.mints = [mint];
        walletEvent.relays = $ndk.pool.permanentAndConnectedRelays().map(r => r.url);
        walletEvent.name = name;
        await walletEvent.sign();
        walletEvent.publish(walletEvent.relaySet);
        closeModal();
    }

    $: if (mint) {
        actionButtons = [
            {
                name: "Create",
                buttonProps: { variant: 'accent' },
                fn: create
            }
        ];
    
    }
</script>

<ModalShell
    title="New Wallet"
    class="max-w-sm w-full"
    {actionButtons}
>
    <label>
        <span>Wallet Name:</span>
        <Input bind:value={name} />
    </label>

    <label>
        <span>Wallet Mint:</span>
        <Input bind:value={mint} />
    </label>

    <Collapsible.Root bind:open={showRecommendations} class="my-4">
        <Collapsible.Trigger>
            <Button>Show Mints</Button>
        </Collapsible.Trigger>
        <Collapsible.Content>
            <RecommendedMintList on:click={selectedMint} />
        </Collapsible.Content>
    </Collapsible.Root>
</ModalShell>