import type { NDKEvent } from "@nostr-dev-kit/ndk";
import { nip19 } from "nostr-tools";

export function removeQuotedEvent(event: NDKEvent): string {
    const quotedEventId = event.tagValue('q');

    if (!quotedEventId) return event.content;

    const content = event.content;
    const bech32 = nip19.noteEncode(quotedEventId);

    const match = new RegExp(`nostr:${bech32}`);
    return content.replace(match, '');
}