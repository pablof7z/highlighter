import NDK, { NDKSubscriptionStart, NDKSubscriptionReceipt } from "@nostr-dev-kit/ndk";
import { calculateEndOfTerm } from "./term";
import { getTierIdFromSubscriptionEvent } from "../events/tiers";

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
    receipt.tags.push(["P", subscription.pubkey])

    const tierDtag = getTierIdFromSubscriptionEvent(subscription);

    if (tierDtag) receipt.tags.push(["tier", tierDtag])
    await receipt.sign();
    await receipt.publish();

    return receipt;
}