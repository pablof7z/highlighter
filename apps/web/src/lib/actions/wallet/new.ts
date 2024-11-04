import { ndk } from "$stores/ndk";
import { walletService } from "$stores/wallet";
import { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
import { get } from "svelte/store";

export async function createNewWallet() {
    const $ndk = get(ndk);
    const $walletService = get(walletService);

    const wallet = new NDKCashuWallet($ndk);
    wallet.name = "Wallet";
    wallet.mints = ["https://mint.minibits.cash/Bitcoin", "https://mint.agorist.space", "https://21mint.me"];   
    wallet.relays = ["wss://relay.damus.io", "wss://relay.primal.net", "wss://relay.nostr.band"];
    const rest = await wallet.publish();

    $walletService.setMintList(wallet);

    return wallet;
}