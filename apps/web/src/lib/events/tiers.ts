import type { Hexpubkey, NDKArticle, NDKEvent, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";

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

export type TierSelectionEntry = {
    name: string;
    selected: boolean;
    event?: NDKArticle;
};
export type TierId = string;
export type TierSelection = Record<TierId, TierSelectionEntry>;
export type Tier = {
    id: TierId;
    name: string;
    event?: NDKArticle;
};

export function getSelectedTiers(tiers: TierSelection): Tier[] {
    const selectedTiers: Tier[] = [];
    for (const tier of Object.keys(tiers)) {
        if (tiers[tier].selected) {
            selectedTiers.push({
                id: tier,
                name: tiers[tier].name,
                event: tiers[tier].event,
            });
        }
    }

    return selectedTiers;
}

export function getTierSelectionFromAllTiers(allTiers: NDKArticle[]) {
    const tiers: TierSelection = {};
    tiers["Free"] = { name: "Free", selected: true };

    for (const tier of allTiers) {
        const dTag = tier.tagValue("d");
        if (dTag && tiers[dTag] === undefined) {
            tiers[dTag] = { name: tier.title ?? dTag, selected: true };
        }
    }

    return tiers;
}