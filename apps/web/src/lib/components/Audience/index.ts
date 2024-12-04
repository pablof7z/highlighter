import Button from "./Button.svelte";
import List from "./List.svelte";
import GroupTiers from "./GroupTiers.svelte";
import { calculateRelaySetFromEvent, NDKEvent, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { ndk } from "$stores/ndk";
import { GroupData } from "$components/Groups";

export type Scope = 'public' | 'communities' | 'private';

export type GroupTierEntry = {
    tierId: string;
    groupId: string;
    relayUrls: string[];
}

export type State = {
    scope?: Scope;
    groups?: GroupData[];
    tiers?: GroupTierEntry[];

    relaySet?: NDKRelaySet;
}

export {
    Button,
    List,
    GroupTiers
}

export function produceTags(state: State, eventType: 'main' | 'preview'): NDKTag[] {
    const tags: NDKTag[] = [];

    if (!state.groups) return tags;
    
    for (const group of state.groups) {
        tags.push(["h", group.id, ...group.relayUrls]);

        if (group.tiers) {
            for (const tier of group.tiers) {
                if (eventType === 'main') {
                    tags.push(["f", tier.dTag??"", group.id ]);
                } else {
                    tags.push(["tier", tier.dTag??"", group.id ]);
                }
            }
        }
    }
    
    return tags;
}

export async function produceRelaySet(state: State, event: NDKEvent): Promise<NDKRelaySet> {
    const $ndk = get(ndk);
    const relaySet = state.relaySet || new NDKRelaySet(new Set(), $ndk);

    // if we have groups, add their relays
    if (state.groups && Object.keys(state.groups).length > 0) {
        for (const group of state.groups) {
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