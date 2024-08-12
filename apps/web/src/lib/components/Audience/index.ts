import Button from "./Button.svelte";
import { calculateRelaySetFromEvent, NDKEvent, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { ndk } from "$stores/ndk";
import { GroupData } from "$components/Groups";

export type Scope = 'public' | 'private';

export type State = {
    scope?: Scope;
    groups?: GroupData[];

    relaySet?: NDKRelaySet;
}

export {
    Button
}

export function produceTags(state: State): NDKTag[] {
    const tags: NDKTag[] = [];

    if (!state.groups) return tags;
    
    for (const group of state.groups) {
        tags.push(["h", group.id, ...group.relayUrls]);
    }
    
    return tags;
}

export async function produceRelaySet(state: State, event: NDKEvent): Promise<NDKRelaySet> {
    const $ndk = get(ndk);
    const relaySet = state.relaySet || new NDKRelaySet(new Set(), $ndk);

    // if we have groups, add their relays
    if (state.groups) {
        for (const group of state.groups) {
            console.log('group', group);
            for (const url of group.relayUrls) {
                const relay = $ndk.pool.getRelay(url, true);
                relaySet.addRelay(relay);
            }
        }
    }

    // if the event is public, add the calculated set of the event
    if (state.scope === 'public') {
        const eventSet = await calculateRelaySetFromEvent($ndk, event);
        for (const relay of eventSet.relays) {
            relaySet.addRelay(relay);
        }
    }
    
    return relaySet;
}