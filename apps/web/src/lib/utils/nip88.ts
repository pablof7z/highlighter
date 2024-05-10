import NDK, { NDKSubscriptionStart, NDKSubscriptionReceipt } from "@nostr-dev-kit/ndk";
import { calculateEndOfTerm } from "./term";
import { getTierIdFromSubscriptionEvent } from "../events/tiers";
import createDebug from "debug";
import { getDefaultRelaySet } from "./ndk";

const d = createDebug('HL:nip88');

export async function publishSubscriptionReceipt(
    ndk: NDK,
    subscription: NDKSubscriptionStart,
) {
    const amount = subscription.amount;
    if (!amount) throw new Error('No amount in subscription');
    const term = amount.term;
    const receipt = new NDKSubscriptionReceipt(ndk);
    receipt.subscriptionStart = subscription;
    receipt.validPeriod = {
        start: new Date(),
        end: calculateEndOfTerm(term, new Date())
    };
    receipt.subscriber = subscription.author;
    receipt.recipient = subscription.recipient;

    const tierDtag = getTierIdFromSubscriptionEvent(subscription);

    if (tierDtag) receipt.tags.push(["tier", tierDtag])
    await receipt.sign();

    d('publishing receipt', receipt.rawEvent());

    await receipt.publish();

    return receipt;
}