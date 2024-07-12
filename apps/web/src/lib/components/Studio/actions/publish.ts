import { ndk } from "$stores/ndk";
import { relaySetForEvent } from "$utils/event";
import { NDKEvent, NDKRelay, NDKRelaySet } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function publish(
    event: NDKEvent,
    publishAt?: Date,
): Promise<void> {
    const $ndk = get(ndk);
    
    event.created_at = undefined;
    event.id = undefined;
    if (publishAt) {
        event.created_at = Math.floor(publishAt.getTime() / 1000);
    }
    
    await event.sign();

    console.log(event.rawEvent())

    const relaySet = NDKRelaySet.fromRelayUrls(["ws://localhost:2929"], $ndk)
    const rest = event.publish(relaySet);
    console.log('publish', rest)
}