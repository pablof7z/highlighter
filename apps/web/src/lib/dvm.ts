import { ndk } from "$stores/ndk.js";
import { NDKEvent, dvmSchedule } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export function getDvmSchedulerPubkey() {
    return "85c20d3760ef4e1976071a569fb363f4ff086ca907669fb95167cdc5305934d1";
}

export async function dvmScheduleEvent(event: NDKEvent, relays: string[] = []) {
    const $ndk = get(ndk);
    const dvmPubkey = getDvmSchedulerPubkey();
    const dvm = $ndk.getUser({pubkey: dvmPubkey})

    return await dvmSchedule(
        event,
        dvm,
        [...relays, "wss://relay.f7z.io", "wss://nos.lol"],
        true,
        5000
    )
}