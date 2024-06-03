import "websocket-polyfill";
import { ndk } from "$stores/ndk";
import { get } from 'svelte/store';
import { Hexpubkey, NDKEvent, NDKFilter, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
import { nip19 } from "nostr-tools";
import { defaultRelays } from "./const";

export const ssr = false;

const timeout = (time: number) => new Promise((_, reject) => {
    setTimeout(() => {
        console.log('rejecting')
        reject(new Error("Timeout"));
    }, time);
});

function chooseImageFromMediaEvents(mediaEvents: NDKEvent[], author: Hexpubkey) {
    let image: string | undefined;
    
    for (const media of mediaEvents) {
        const i = media.tagValue("url");
        if (i) {
            image = i;

            // if the author is the author of the media, we're done
            if (media.pubkey === author) break;
        }
    }

    return image;
}

export async function fetchEvent(id: string) {
    const $ndk = get(ndk);
    let event: NDKEvent | null | undefined;
    let image: string | undefined;

    try {
        await $ndk.connect(1000);
    } catch (e) {
        console.log("error", e)
        return {};
    }

    const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);

    try {
        const decode = nip19.decode(id);
        const promises: Promise<any>[] = [];

        promises.push(new Promise<void>(async (resolve, reject) => {
            event = await $ndk.fetchEvent(id, undefined, relaySet);
            console.log(id);
            console.log(event?.kind);
            resolve();
        }));

        if (decode.type === "naddr") {
            const {kind, pubkey, identifier} = decode.data;
            const aTag = [kind,pubkey,identifier].join(":");

            promises.push(new Promise<void>(async (resolve, reject) => {
                const mediaEvent = await $ndk.fetchEvents([
                    // one 1063 query by the author of the event
                    {kinds: [NDKKind.Media], "#a": [aTag], authors: [pubkey], limit: 1},

                    // a few extra just in case the author didn't publish one
                    {kinds: [NDKKind.Media], "#a": [aTag], limit: 5},
                ], undefined, relaySet);

                image = chooseImageFromMediaEvents(Array.from(mediaEvent), pubkey);
                resolve();
            }));
        }

        promises.push(timeout(1500));

        console.log("waiting for promises");
        await Promise.race(promises).catch(() => console.log('caught'));
        console.log("promises done");
    } catch { return {}; }

    const ret: Record<any, any> = {};

    if (event) ret.event = event.rawEvent();
    if (image) ret.image = image;

    console.log(ret)

    return ret;
}
