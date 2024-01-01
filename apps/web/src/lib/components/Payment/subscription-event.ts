import type { Term } from "$utils/term";
import NDK, { NDKEvent, NDKUser, type NostrEvent } from "@nostr-dev-kit/ndk";

export async function createSubscriptionEvent(
    ndk: NDK,
    amount: string,
    currency: string,
    term: Term,
    plan?: NDKEvent,
    supportedUser?: NDKUser,
) {
    const supportEvent = new NDKEvent(ndk, {
        kind: 7001,
        tags: [
            [ "amount", amount, currency, term ],
        ]
    } as NostrEvent);

    if (plan) {
        supportEvent.tags.push([ "event", JSON.stringify(plan.rawEvent()) ]);
        supportEvent.tag(plan);
    } else {
        supportEvent.tag(supportedUser!);
    }

    await supportEvent.sign();
    return supportEvent;
}
