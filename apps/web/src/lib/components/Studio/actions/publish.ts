import { ndk } from "$stores/ndk";
import { NDKEvent, NDKRelay, NDKRelaySet } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

function relaysToPublishTo(event: NDKEvent) {
    const hTags = event.getMatchingTags("h");
    const relayUrls = new Set<string>();

    for (const hTag of hTags) {
        const relayUrl = hTag[2];
        if (relayUrl) relayUrls.add(relayUrl);
    }

    return Array.from(relayUrls);
}

export async function publish(
    event: NDKEvent,
    publishAt?: Date,
): Promise<NDKEvent> {
    const $ndk = get(ndk);
    
    event.created_at = undefined;
    event.id = undefined;
    if (publishAt) {
        event.created_at = Math.floor(publishAt.getTime() / 1000);
    }
    
    await event.sign();

    const relaySet = NDKRelaySet.fromRelayUrls(["ws://localhost:2929"], $ndk)
    const rest = await event.publish(relaySet);
    return event;
}