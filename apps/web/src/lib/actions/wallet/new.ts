import { ndk } from "$stores/ndk";
import { NDKCashuWallet } from "$utils/cashu/wallet";
import { NDKRelaySet } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function createNewWallet() {
    const $ndk = get(ndk);
    const wallet = new NDKCashuWallet($ndk);
    wallet.name = "Wallet";
    wallet.mints = ["https://mint.minibits.cash/Bitcoin", "https://mint.agorist.space"];
    wallet.relays = ["wss://relay.damus.io", "wss://nos.lol", "wss://relay.nostr.band"];
    const relaySet = NDKRelaySet.fromRelayUrls(wallet.relays, $ndk);
    console.log("publishing wallet", wallet.rawEvent());
    const rest = await wallet.publish(relaySet);
    console.log("published wallet", rest);
    return wallet;
}