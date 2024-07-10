<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
	import InputArray from "$components/ui/input/InputArray.svelte";
	import CashuMintSelectorModal from "$modals/CashuMintSelectorModal.svelte";
	import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKCashuWallet } from "$utils/cashu/wallet";
	import { openModal } from "$utils/modal";
	import { NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { Block } from "konsta/svelte";
	import { onDestroy } from "svelte";

    $layout.back = { url: "/wallet" }
    $layout.options = [
        { name: "Save", fn: save }
    ]

    onDestroy(() => {
        $layout.options = [];
    })

    const eventId = $page.url.searchParams.get("id");
    let wallet: NDKCashuWallet;
    let name: string;
    let relays: string[] = [];
    let mints: string[] = [];

    if (eventId) {
        $ndk.fetchEvent(eventId)
            .then(async (e) => {
                if (e) {
                    wallet = await NDKCashuWallet.from(e);
                    $layout.title = wallet.name ?? wallet.dTag;
                    name = wallet.name ?? wallet.dTag ?? "";
                    relays = wallet.relays;
                    mints = wallet.mints;
                    relaySet = NDKRelaySet.fromRelayUrls(wallet.relays, $ndk);
                    console.log({relaySet: relaySet.relayUrls})
                    relaySet.relays.forEach((r) => console.log(r.status, r.url));
                }
            });
    }

    let relaySet: NDKRelaySet

    async function save() {
        if (!wallet) return;

        wallet.name = name;
        wallet.relays = relays;
        wallet.mints = mints;
        console.log(wallet.rawEvent());
        await wallet.publishReplaceable();
        goto("/wallet");
    }

</script>

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
            <InputArray bind:values={mints}>
                <svelte:fragment slot="extrabuttons">
                    <Button variant="secondary" class="mt-6 self-end w-fit px-6"
                        on:click={() => openModal(CashuMintSelectorModal, {
                            onClick: (mint) => mints = [...mints, mint]
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
            <InputArray bind:values={relays} />
        </div>
    </div>

    <div class="my-10">
        <Button variant="accent" class="w-full" on:click={save}>
            Save
        </Button>
    </div>
</Block>