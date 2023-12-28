import type { Hexpubkey, NDKEvent, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";

export function requiredTiersFor(event: NDKEvent, addFreeIfEmpty = true) {
    let tiers: NDKTag[] = event.getMatchingTags("tier");

    if (!tiers || tiers.length === 0) tiers = event.getMatchingTags("f");

    if (!tiers || tiers.length === 0) {
        if (addFreeIfEmpty)
            return ["Free"];
        else
            return [];
    }

    return tiers.map(t => t[1]);
}

/**
 * CHecks if the user can comment on the event
 */
export function canUserComment(event: NDKEvent, user: NDKUser, activeSubscriptions: Map<Hexpubkey, string>) {
    if (event.pubkey === user?.pubkey) return true;

    const requiredTiers = requiredTiersFor(event, false);
    if (requiredTiers && requiredTiers.includes("Free")) return true;

    const groupId = event.tagValue("h");
    if (!groupId) return true;
    const subscription = activeSubscriptions.get(groupId);

    if (!subscription) return false;
    return requiredTiers.includes(subscription);
}