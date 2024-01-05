import { NDKEvent, NDKUser, type NDKTag, type NostrEvent, NDKPrivateKeySigner } from "@nostr-dev-kit/ndk";
import { getDefaultRelaySet } from "./ndk";
import { get } from "svelte/store";
import { ndk, user } from "@kind0/ui-common";
import createDebug from "debug";

let flushTimer: number | undefined = 10000;

const queue: NDKTag[] = [];
let timeout: NodeJS.Timeout | undefined = undefined;

const d = createDebug("highlighter:read-receipts");

let signer: NDKPrivateKeySigner | undefined = undefined;

/**
 * Adds a kind:15 event tagging seen events.
 */
export function addReadReceipt(eventOrUser: NDKEvent | NDKUser): void {
    const $user = get(user);

    if ($user?.pubkey === eventOrUser.pubkey) return;

    if (eventOrUser instanceof NDKEvent) {
        const tags = eventOrUser.referenceTags();

        for (const tag of tags) {
            if (["a", "e"].includes(tag[0])) queue.push(tag);
        }
    } else {
        queue.push(["p", eventOrUser.pubkey]);
    }

    d("Read receipt", queue);

    if (!timeout) {
        timeout = setTimeout(() => {
            timeout = undefined;
            flushReadReceipts();
        }, flushTimer);
    }
}

/**
 * Tracks how long it takes to sign this events to assess whether
 * we are asking the user constantly and being annoying.
 */
const signatureTimes: number[] = [];

export async function flushReadReceipts(): Promise<void> {
    const $ndk = get(ndk);

    console.log("Flushing seen events queue", queue);
    const tags = queue.splice(0, queue.length);

    if (timeout) {
        clearTimeout(timeout);
        timeout = undefined;
    }

    if (!tags.length) return;

    const event = new NDKEvent($ndk, {
        kind: 15,
        tags
    } as NostrEvent);

    const signStartTime = Date.now();

    try {
        await event.sign(signer);

        // Check how long it took to sign the event
        const totalSignTime = Date.now() - signStartTime;
        signatureTimes.push(totalSignTime);

        adjustFlushTimer();
    } catch (error) {
        // If we can't sign the event, use an anonymous signer
        // so we can still publish the event
        signer = NDKPrivateKeySigner.generate();
        await event.sign(signer);
    }


    await event.publish(getDefaultRelaySet());
}

function adjustFlushTimer() {
    if (!flushTimer) return;

    // If it took 3 times longer than 5 seconds to sign events, increase the flush timer
    if (
        signatureTimes.length >= 3 && // Only start adjusting after 3 events
        signatureTimes.slice(-3).every(time => time >= 5000) && // All 3 events took longer than 5 seconds
        signatureTimes.slice(-1)[0] >= 5000 // The last event took longer than 5 seconds
    ) {
        flushTimer = Math.min(30000, flushTimer * 2);
    }
}