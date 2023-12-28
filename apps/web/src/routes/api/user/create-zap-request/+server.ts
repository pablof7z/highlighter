import "websocket-polyfill";
import db from "$lib/db";
import { get as getStore } from "svelte/store";
import { ndk } from "@kind0/ui-common";
import { json, text } from "@sveltejs/kit"
import createDebug from "debug";
import type { Session } from "../../../../app.js";
import { webln } from "@getalby/sdk";
import { NDKArticle, NDKEvent, NDKUser, NDKZap } from "@nostr-dev-kit/ndk";

const log = createDebug("fans:/api/user/create-zap-request");

type Payload = {
    event: string;
    comment?: string;
}

function getRecipient(event: NDKEvent): NDKUser {
    const $ndk = getStore(ndk)
    const pTag = event.tagValue("p");
    return $ndk.getUser({pubkey: pTag});
}

async function getBitcoinPrice() {
    const response = await fetch("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
    const data = await response.json();
    return data.bitcoin.usd;
}

async function calculateAmount(event: NDKEvent): Promise<number> {
    const bitcoinPrice = await getBitcoinPrice();
    const amountTag = event.getMatchingTags("amount")[0];

    if (!amountTag) throw new Error("Amount not found");

    const value = parseFloat(amountTag[1]);
    const currency = amountTag[2];

    if (currency === "USD") {
        return Math.floor(Number(value) / bitcoinPrice * 100_000_000); // expressed in USD in the tag
    } else if (currency === "msat") {
        return value / 1000; // expressed in msats in the tag
    } else {
        throw new Error("Currency not supported");
    }
}

function getTierNameFromSubscriptionEvent(event: NDKEvent): string | undefined {
    const tierEventString = event.tagValue("event");

    if (!tierEventString) return undefined;

    const tierEvent = new NDKArticle(undefined, JSON.parse(tierEventString));
    return tierEvent.title;
}

function calculateValidUntil(event: NDKEvent): Date {
    const amountTag = event.getMatchingTags("amount")[0];
    const cadennce = amountTag[3];
    const now = new Date();

    if (cadennce === "monthly") {
        now.setMonth(now.getMonth() + 1);
    } else if (cadennce === "yearly") {
        now.setFullYear(now.getFullYear() + 1);
    } else if (cadennce === "quarterly") {
        now.setMonth(now.getMonth() + 3);
    } else if (cadennce === "weekly") {
        now.setDate(now.getDate() + 7);
    } else if (cadennce === "daily") {
        now.setDate(now.getDate() + 1);
    } else {
        throw new Error("Cadence not supported");
    }

    return now;
}

export async function POST({request, locals}) {
    console.log("POST /api/user/create-zap-request", request);
    try {
        const $ndk = getStore(ndk)
        const {pubkey} = locals.session as Session;
        const payload = await request.json();
        const { event: eventData } = payload as Payload;
        let { comment } = payload as Payload;
        console.log("event", eventData);
        const event = new NDKEvent($ndk, JSON.parse(eventData));
        console.log("event", event.rawEvent());
        const recipient = getRecipient(event);
        let satsAmount = await calculateAmount(event);

        satsAmount = 100;

        const tierName = getTierNameFromSubscriptionEvent(event);

        if (!recipient) throw new Error("Recipient not found");

        const zap = new NDKZap({
            ndk: $ndk,
            zappedEvent: event,
            zappedUser: recipient
        });
        comment ??= `Zap from getfaaans`;

        const timeoutPromise = new Promise<boolean>((_, reject) => {
            setTimeout(() => reject(new Error("Timeout")), 6000);
        });

        const getZapPromise = new Promise((resolve, reject) => {
            console.log("generating zap request");
            zap.generateZapRequest(satsAmount, comment).then((res) => {
                console.log("zap request generated", res);
                if (!res) reject(new Error("Zap request not generated"));
                resolve(res);
            }).catch((e) => {
                console.log("error generating zap request", e);
                console.log("error", e);
                reject(e);
            });
        });

        const a = await Promise.race([
            getZapPromise,
            timeoutPromise
        ]).catch((e) => {
            console.log("error", e);
            throw e;
        });

        console.log({a});

        const {event: zapReq, zapEndpoint} = a as any;
        zapReq.pubkey = pubkey;
        await zapReq.toNostrEvent();

        // save zap request to db
        const record = await db.payment.create({
            data: {
                id: zapReq.id,
                payerPubkey: pubkey,
                zapRequest: JSON.stringify(zapReq.rawEvent()),
                receiverPubkey: recipient.pubkey,
                tierName,
                zappedEvent: JSON.stringify(event.rawEvent()),
                zapEndpoint,
                satsAmount,
                validUntil: calculateValidUntil(event),
                paid: false
            }
        });

        console.log({record});

        return json({event: zapReq.rawEvent()});
    } catch (error: any) {
        console.log(error);
        log(error);
        return text(error.message, { status: 400 });
    }
}
