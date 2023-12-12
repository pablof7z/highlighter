import { NDKEvent, type NostrEvent } from "@nostr-dev-kit/ndk";
import { NDKFilter } from "../node_modules/@nostr-dev-kit/ndk/dist/index";

type SubscriptionDetails = Record<string, string[]>;

const subscriptions: Record<string, SubscriptionDetails> = {
    "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52": {
        "82fbb08c8ef45c4d71c88368d0ae805bc62fb92f166ab04a0b7a0c83d8cbc29a": [
            "White Rabbit"
        ]
    }
};

function allowAuthorOnTheirOwnGroup(filter: NDKFilter, groups: string[], pubkey: string): boolean | undefined {
    if (
        groups?.length === 1 &&
        groups[0] === pubkey
    ) return true;
}

function allowQueryingForFreeItems(filter: NDKFilter, groups: string[], pubkey: string): boolean | undefined {
    if (
        filter["#f"]?.length === 1 &&
        filter["#f"][0] === "Free"
    ) return true;
}

function allowQueryingForInformativeItems(filter: NDKFilter, groups: string[], pubkey: string): boolean | undefined {
    const onlyAllowedKinds = [ 17001, 7001, 0, 37777, 30023 ];
    const requestedKinds = filter.kinds;

    // if the requested kinds are all in the allowed kinds, then allow it
    if (requestedKinds?.every(kind => onlyAllowedKinds.includes(kind))) return true;
}

function allowActiveSubscribers(filter: NDKFilter, groups: string[], pubkey: string): boolean | undefined {
    const tiers = filter["#f"];

    if (!tiers) return;

    for (const group of groups) {
        for (const tier of tiers) {
            const tierSubs = subscriptions[pubkey]?.[group]?.includes(tier);

            if (!tierSubs) return;
        }
    }

    return true;
}

type Connection = {
    ip?: string,
    pubkey?: string,
    store?: Object
};

export default function test(filter: NDKFilter, relay: any, connection: Connection) {
    if (!connection.pubkey) {
        console.log("Authentication required");
        return "auth-required: Authentication required"
    }

    const groups = filter["#h"];

    try {
        if (allowQueryingForFreeItems(filter, groups, connection.pubkey)) return;
        if (allowQueryingForInformativeItems(filter, groups, connection.pubkey)) return;
        if (groups) {
            if (allowAuthorOnTheirOwnGroup(filter, groups, connection.pubkey)) return;
            if (allowActiveSubscribers(filter, groups, connection.pubkey)) return;
        }
    } catch (e) {
        console.trace(e);
        return e.message;
    }

    console.log("Would not have allowed", JSON.stringify(filter), connection.pubkey);

    // return "not-allowed: Not allowed to run "+JSON.stringify(filter)+" on this node";
}
