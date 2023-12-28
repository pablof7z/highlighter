import { NDKEvent, NDKUser, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
import { getDefaultRelaySet } from "./ndk";
import { get } from "svelte/store";
import { ndk, user } from "@kind0/ui-common";
import createDebug from "debug";

const FLUSH_TIMEOUT = 10000;

const queue: NDKTag[] = [];
let timeout: NodeJS.Timeout | undefined = undefined;

const d = createDebug("fans:read-receipts");

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
        }, FLUSH_TIMEOUT);
    }
}

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
    await event.publish(getDefaultRelaySet());
}