import type { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";

export function requiredTiersFor(event: NDKEvent) {
    let tiers: NDKTag[] = event.getMatchingTags("tier");

    if (!tiers || tiers.length === 0) tiers = event.getMatchingTags("f");

    if (!tiers || tiers.length === 0) return ["Free"];

    return tiers.map(t => t[1]);
}