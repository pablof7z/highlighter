import db from "$lib/db";
import { webln } from "@getalby/sdk";
import type { Hexpubkey } from "@nostr-dev-kit/ndk";
import createDebug from "debug";

const debug = createDebug("highlighter:payments:pay");

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
    debug(`Sending payment for ${pubkey}`);
    const nwc = new webln.NWC({ nostrWalletConnectUrl: nwcUri });

    debug("enabling nwc");
    await nwc.enable();
    debug("sending payment");
    const res = await nwc.sendPayment(invoice);
    debug("payment sent", res);
    return res;
}