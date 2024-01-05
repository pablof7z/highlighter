import { sendPayment } from "$lib/backend/pay";
import { ndk } from "@kind0/ui-common";
import { NDKEvent, NDKUser, NDKZap } from "@nostr-dev-kit/ndk";
import { json } from "@sveltejs/kit";
import { get } from "svelte/store";
import createDebug from "debug";
import "websocket-polyfill";
import { calculateSatAmountFromAmountTag } from "$utils/currency";
import { addToListOfSupporters, getTierNameFromSubscriptionEvent } from "$utils/subscriptions";
import { validateEvent, verifySignature, type Event } from "nostr-tools";

const debug = createDebug("highlighter:/api/user/subscribe");

type Payload = {
    subscriptionEvent: string;
}

function getRecipient(event: NDKEvent): NDKUser {
    const $ndk = get(ndk)

    // if there are more than one p tag, throw
    const pTagCount = event.getMatchingTags("p").length;
    if (pTagCount !== 1) {
        throw new Error(`Found ${pTagCount} p tags, expected 1`);
    }

    const pTag = event.tagValue("p");
    return $ndk.getUser({pubkey: pTag});
}

async function getPaymentRequest(event: NDKEvent): Promise<string | null> {
    const $ndk = get(ndk)

    const recipient = getRecipient(event);
    const amountTag = event.getMatchingTags("amount")[0];
    if (!amountTag) throw new Error("Amount not found");

    const satsAmount = 10; // await calculateSatAmountFromAmountTag(amountTag);
    const tierName = getTierNameFromSubscriptionEvent(event);
    let comment = `Faaans subscription`;
    if (tierName) comment += `to ${tierName}`;

    const zap = new NDKZap({
        ndk: $ndk,
        zappedEvent: event,
        zappedUser: recipient
    });

    const pr = await zap.createZapRequest(
        satsAmount * 1000,
        comment,
    );

    debug("payment request", pr);

    return pr;
}

export async function POST({request}) {
    const payload = await request.json();
    const { subscriptionEvent } = payload as Payload;
    const $ndk = get(ndk)

    try {
        const event = new NDKEvent($ndk, JSON.parse(subscriptionEvent));
        debug(event.rawEvent());

        // validate this event since it's not coming from a relay
        // and we need to make sure that the signature is valid
        if (!await verifySignature(event.rawEvent() as Event)) {
            throw new Error("Invalid signature");
        }

        const recipient = getRecipient(event);
        debug("getting payment request")
        const pr = await getPaymentRequest(event);
        debug("payment request", pr);

        if (!pr) {
            throw new Error("Unable to generate a payment request");
        }

        // const paymentResult = { mocked: 'yup!' };
        const paymentResult = await sendPayment(pr, event.pubkey);
        debug("payment result", paymentResult);

        await Promise.all([
            new Promise((resolve) => {
                event.publish().then((relays) => {
                    debug(`event published to ${relays.size} relays`);
                    resolve(null);
                });
            }),
            new Promise((resolve) => {
                addToListOfSupporters(
                    $ndk,
                    recipient.pubkey,
                    event
                ).then(resolve)
                .catch((e) => {
                    debug("error adding to list of supporters", e);
                    resolve(null);
                })
            })
        ])

        return json(paymentResult);
    } catch (error: any) {
        debug('err', {error});
        return json(error, { status: 400 });
    }
}