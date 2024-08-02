import { ndk } from "$stores/ndk";
import { walletService } from "$stores/wallet";
import { get } from "svelte/store";

export async function createNewWallet() {
    const $ndk = get(ndk);
    const $walletService = get(walletService);

    const wallet = $walletService.createCashuWallet();
    wallet.name = "Wallet";
    wallet.mints = ["https://mint.minibits.cash/Bitcoin", "https://mint.agorist.space", "https://21mint.me"];   
    wallet.relays = ["wss://relay.damus.io", "wss://relay.primal.net", "wss://relay.f7z.io", "wss://relay.highlighter.com", "wss://relay.nostr.band"];
    debugger
    await wallet.sign();
    const rest = await wallet.publish(wallet.relaySet);

    $walletService.setMintList(wallet);

    return wallet;
}