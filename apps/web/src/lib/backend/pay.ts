import db from "$lib/db";
import { webln } from "@getalby/sdk";
import type { Hexpubkey } from "@nostr-dev-kit/ndk";

async function getNwcString(pubkey: string) {
    const wallet = await db.walletConnect.findUnique({
        where: { pubkey },
    });

    if (!wallet) {
        throw new Error("Wallet not connected");
    }

    return wallet.uri;
}

export async function sendPayment(invoice: string, pubkey: Hexpubkey): Promise<string> {
    const nwcUri = await getNwcString(pubkey);
    const nwc = new webln.NWC({ nostrWalletConnectUrl: nwcUri });

    await nwc.enable();
    return await nwc.sendPayment(invoice);
}