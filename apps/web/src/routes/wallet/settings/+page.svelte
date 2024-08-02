<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
	import InputArray from "$components/ui/input/InputArray.svelte";
	import CashuMintSelectorModal from "$modals/CashuMintSelectorModal.svelte";
	import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { walletService, wallet as defaultWallet, wallets } from "$stores/wallet";
	import { openModal } from "$utils/modal";
	import { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
	import { Block } from "konsta/svelte";
	import { Key } from "phosphor-svelte";
	import { stringify } from "querystring";
	import { onDestroy } from "svelte";
	import { toast } from "svelte-sonner";
	import { derived, writable } from "svelte/store";

    $layout.back = { url: "/wallet" }
    $layout.options = [
        { name: "Save", fn: save }
    ]

    onDestroy(() => {
        $layout.options = [];
    })

    const walletId = $page.url.searchParams.get("id");
    let name: string;
    const relays = writable<string[]>([]);
    const mints = writable<string[]>([]);

    let wallet: NDKCashuWallet | undefined;
    
    if (!wallet) wallet = $wallets.find((w) => w.dTag === walletId);

    $: if (!name && wallet) {
        name = wallet.name ?? "Wallet";
        $relays = wallet.relays;
        $mints = wallet.mints;
    }

    async function makeDefault() {
        if (!wallet) return;
        await $walletService.setMintList(wallet);

        toast.success("Wallet set as default");
    }

    async function checkProofs() {
        console.log("Checking proofs", wallet);
        if (!wallet) return;
        await wallet.checkProofs();
    }

    async function save() {
        if (!wallet) return;

        wallet.name = name ?? "Wallet";
        wallet.relays = $relays;
        console.log('setting relays', $relays);
        wallet.mints = $mints;
        console.log(wallet.rawEvent());
        await wallet.publishReplaceable();
        goto("/wallet");
    }

    let confirmDelete = false;
    async function onDelete() {
        if (confirmDelete && wallet) {
            await wallet.delete();
            goto("/wallet");
            toast("Wallet deleted");
        } else {
            confirmDelete = true;
            setTimeout(() => confirmDelete = false, 3000);
        }
    }

    async function generateSpendingKey() {
        if (!wallet) return;
        
        wallet.skipPrivateKey = false;
        await wallet?.toNostrEvent();
        console.log(wallet?.privkey);
    }
</script>

{#if wallet}
    <Block>
        <div class="flex flex-col gap-6 w-full items-start">
            <div class="w-full">
                <h1>Name</h1>
                <Input bind:value={name} />
            </div>

            <div class="w-full">
                <h2 class="mb-0">Mints</h2>
                <div class="text-sm text-muted-foreground mb-4">
                    Choose the mints where you want to store the wallet's value.
                </div>
                <InputArray values={mints}>
                    <svelte:fragment slot="extrabuttons">
                        <Button variant="secondary" class="mt-6 self-end w-fit px-6"
                            on:click={() => openModal(CashuMintSelectorModal, {
                                onClick: (mint) => $mints = [...$mints, mint]
                            })}>
                            Browse Mints
                        </Button>
                    </svelte:fragment>
                </InputArray>
            </div>

            <div class="w-full">
                <h2 class="mb-0">Relays</h2>
                <div class="text-sm text-muted-foreground mb-4">
                    These are the relays where the wallet information will be stored.
                </div>
                <InputArray values={relays} />
                {JSON.stringify($relays)}
            </div>
        </div>

        <h1>Spending Key</h1>
        {#if wallet?.p2pkPubkey}
            Wallet has a spending key

            {wallet.privkey}
        {:else}
            <p>Wallet doesn't have a spending key</p>

            <Button variant="accent" class="w-full" on:click={generateSpendingKey}>
                <Key size={24} class="mr-2" />
                Generate Spending Key
            </Button>
        {/if}

        <pre>{JSON.stringify(wallet?.rawEvent(), null, 2)}</pre>

        <div class="my-10 flex flex-col gap-6">
            <Button variant="accent" class="w-full" on:click={save}>
                Save
            </Button>

            <Button variant="secondary" class="w-full" on:click={makeDefault}>
                Make Default
            </Button>

            <Button variant="secondary" class="w-full" on:click={checkProofs}>
                Force Sync
            </Button>

            <Button variant="destructive" class="w-full" disabled={$defaultWallet?.dTag === wallet?.dTag} on:click={onDelete}>
                {#if confirmDelete}
                    Are you sure?
                {:else}
                    Delete Wallet
                {/if}
            </Button>
        </div>
    </Block>
{/if}