import type { Term } from "$utils/term";
import NDK, { NDKEvent, NDKUser, type NostrEvent } from "@nostr-dev-kit/ndk";
import { get as getStore } from "svelte/store";
import { ndk } from "@kind0/ui-common";

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

export async function createZapRequest(event: NDKEvent, comment: string) {
    const $ndk = getStore(ndk);
    const res = await fetch("/api/user/create-zap-request", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            event: JSON.stringify(event.rawEvent()),
            comment,
        }),
    });

    if (res.status !== 200) {
        throw new Error(await res.text());
    }

    const data = await res.json();

    return new NDKEvent($ndk, data.event);
}