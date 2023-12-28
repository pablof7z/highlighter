import "websocket-polyfill";
import db from "$lib/db";
import { get as getStore } from "svelte/store";
import { ndk } from "@kind0/ui-common";
import { json } from "@sveltejs/kit"
import createDebug from "debug";
import type { Session } from "../../../../app.js";
import { webln } from "@getalby/sdk";
import NDK, { NDKEvent, NDKZap, type NostrEvent, NostrEvent, NDKKind, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
import { sendPayment } from "$lib/backend/pay.js";
import type { Payment } from "@prisma/client";
import { calculateValidUntil } from "$utils/payment.js";
import { getDefaultRelaySet } from "$utils/ndk.js";

const log = createDebug("fans:/api/user/pay-zap-request");

type Payload = {
    zapRequest: string;
}

export async function POST({request, locals}) {
    try {
        const $ndk = getStore(ndk)
        const {pubkey} = locals.session as Session;
        console.log("/api/user/pay-zap-request", pubkey);
        const payload = await request.json();
        const { zapRequest: eventData } = payload as Payload;
        console.log("zapRequest", eventData);
        const {id, sig} = new NDKEvent($ndk, JSON.parse(eventData));
        const record = await db.payment.findUnique({where: {id}});
        console.log("record", record);

        if (!record) throw new Error("Payment not found");

        const { satsAmount, receiverPubkey, zappedEvent, zapEndpoint} = record;
        const zapRequest = new NDKEvent($ndk, JSON.parse(record.zapRequest));
        zapRequest.sig = sig;

        const recipient = $ndk.getUser({pubkey: receiverPubkey});
        if (!recipient) throw new Error("Recipient not found");

        const zap = new NDKZap({
            ndk: $ndk,
            zappedEvent: new NDKEvent($ndk, JSON.parse(zappedEvent)),
            zappedUser: recipient
        });

        console.log("fetching invoice");
        const invoice = await zap.getInvoice(zapRequest, satsAmount * 1000, zapEndpoint);
        if (!invoice) throw new Error("Unable to retrieve invoice from destination");

        console.log("paying invoice", invoice);
        const payment = await sendPayment(invoice, pubkey);

        if (payment.preimage) {
            console.log("Payment sent", payment);
            await markSubscriberPayment(id);
        } else {
            console.log("Payment failed", payment);
        }

        return json(payment);
    } catch (error: any) {
        console.log(error);
        log(error);
        return json(error, { status: 401 });
    }
}

async function markSubscriberPayment(id: string) {
    await db.payment.update({where: {id}, data: {paid: true}});

    const record = await db.payment.findUnique({where: {id}});

    if (!record) throw new Error("Payment record not found with id: " + id);

    const $ndk = getStore(ndk);

    // update the list of supporters of this creator
    console.log("publishing events");
    await Promise.all([
        publishPaymentReceivedEvent(record),
        publishListOfSupporters($ndk, record.receiverPubkey),
        publishMemberAcceptedEvent(record),
    ])
}

async function publishMemberAcceptedEvent(record: Payment) {
    const $ndk = getStore(ndk);
    const group = new NDKSimpleGroup($ndk, record.receiverPubkey, getDefaultRelaySet());
    const user = $ndk.getUser({pubkey: record.payerPubkey});
    await group.addUser(user, {
        marker: record.tierName ?? undefined,
    });
}

/**
 * Publishes a payment received event.
 */
async function publishPaymentReceivedEvent(record: Payment) {
    const $ndk = getStore(ndk);
    console.log("publishing payment received event");
    const validUntil = calculateValidUntil(new NDKEvent($ndk, JSON.parse(record.zappedEvent)));
    console.log("valid until", validUntil);
    const event = new NDKEvent($ndk, {
        kind: 7003,
        content: "Payment received for getfaaans.com subscription",
        tags: [
            [ "p", record.payerPubkey],
            [ "P", record.receiverPubkey],
            [ "tier", record.tierName],
            [ "until", Math.floor(validUntil.getTime() / 1000).toString()],
        ]
    } as NostrEvent);

    try {
        const published = await event.publish();
        console.log("Payment received event published" + published.size + " relays", event.rawEvent());
    } catch (error: any) {
        const retry = setInterval(async () => {
            const published = await event.publish();
            console.log("Payment received event published" + published.size + " relays", event.rawEvent());
            clearInterval(retry);
        }, 5000);
        console.log(error);
        log(error);
    }
}

/**
 * Creates a list of pubkeys that are currently supporting a creator.
 * The "d" tag is the pubkey of the creator.
 * THe "p" tag is the pubkey of the supporter with a marker of the tier they are supporting.
 */
async function publishListOfSupporters(ndk: NDK, creatorPubkey: string) {
    const payments = await db.payment.findMany({
        where: {
            receiverPubkey: creatorPubkey,
            paid: true,
            validUntil: {
                gt: new Date()
            }
        }
    });

    const event = new NDKEvent(ndk, {
        kind: NDKKind.GroupMembers,
        content: "",
        tags: [ [ "d", creatorPubkey] ]
    } as NostrEvent);

    const subscribers: Record<string, string[]> = {};

    for (const payment of payments) {
        if (!payment.payerPubkey) continue;

        subscribers[payment.payerPubkey] ??= [];

        if (!subscribers[payment.payerPubkey].includes(payment.tierName!)) {
            subscribers[payment.payerPubkey].push(payment.tierName!);
        }
    }

    for (const [pubkey, tiers] of Object.entries(subscribers)) {
        for (const tier of tiers) {
            event.tags.push(["p", pubkey, tier]);
        }
    }

    await event.publish();
    console.log("List of supporters event", event.rawEvent());
}