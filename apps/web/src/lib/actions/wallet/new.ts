import { ndk } from "$stores/ndk";
import { walletService } from "$stores/wallet";
import { get } from "svelte/store";

export async function createNewWallet() {
    const $ndk = get(ndk);
    const $walletService = get(walletService);

    const wallet = $walletService.createCashuWallet();
    wallet.name = "Wallet";
    wallet.mints = ["https://mint.minibits.cash/Bitcoin", "https://mint.agorist.space"];
    wallet.relays = ["wss://relay.damus.io", "wss://nos.lol", "wss://relay.nostr.band"];
    await wallet.sign();
    const rest = await wallet.publish(wallet.relaySet);

    $walletService.setMintList(wallet);

    return wallet;
}