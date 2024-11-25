<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
	import InputArray from "$components/ui/input/InputArray.svelte";
	import CashuMintSelectorModal from "$modals/CashuMintSelectorModal.svelte";
	import { layout } from "$stores/layout";
	import { walletService, wallet } from "$stores/wallet";
	import { openModal } from "$utils/modal";
	import { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
	import { Key } from "phosphor-svelte";
	import { onDestroy } from "svelte";
	import { toast } from "svelte-sonner";
	import { derived, writable } from "svelte/store";

    $layout.back = { url: "/$wallet" }
    $layout.options = [
        { name: "Save", fn: save }
    ]

    onDestroy(() => {
        $layout.options = [];
    })

    const cashuWallet = $wallet as NDKCashuWallet;

    const walletId = $page.url.searchParams.get("id");
    let name: string = cashuWallet?.name ?? "Wallet";
    const relays = writable<string[]>(cashuWallet?.relays ?? []);
    console.log('relays', cashuWallet?.relays);
    const mints = writable<string[]>(cashuWallet?.mints ?? []);

    async function makeDefault() {
        if (!cashuWallet) return;
        await $walletService.setMintList(cashuWallet);

        toast.success("Wallet set as default");
    }

    async function checkProofs() {
        if (!cashuWallet) return;
        await cashuWallet.checkProofs();
    }

    console.log('event', cashuWallet?.event.rawEvent());

    async function save() {
        if (!cashuWallet) return;

        cashuWallet.name = name ?? "Wallet";
        cashuWallet.relays = $relays;
        cashuWallet.mints = $mints;
        console.log(cashuWallet.event.rawEvent());
        await cashuWallet.publish();
        goto("/wallet");
    }

    let confirmDelete = false;
    async function onDelete() {
        if (confirmDelete && $wallet) {
            await cashuWallet.delete();
            goto("/wallet");
            toast("Wallet deleted");
        } else {
            confirmDelete = true;
            setTimeout(() => confirmDelete = false, 3000);
        }
    }

    async function generateSpendingKey() {
        if (!$wallet) return;
        
        $wallet.skipPrivateKey = false;
        await $wallet?.event.toNostrEvent();
        console.log($wallet?.privkey);
    }
</script>

{#if $wallet}
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
                    These are the relays where the $wallet information will be stored.
                </div>
                <InputArray values={relays} />
                {JSON.stringify($relays)}
            </div>
        </div>

        {#if !cashuWallet?.privkey}
            <h1>Spending Key</h1>
            <p>Wallet doesn't have a spending key</p>

            <Button variant="accent" class="w-full" on:click={generateSpendingKey}>
                <Key size={24} class="mr-2" />
                Generate Spending Key
            </Button>
        {/if}

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

            <!-- <Button variant="destructive" class="w-full" disabled={$defaultWallet?.walletId === $wallet?.walletId} on:click={onDelete}>
                {#if confirmDelete}
                    Are you sure?
                {:else}
                    Delete Wallet
                {/if}
            </Button> -->
        </div>
{/if}