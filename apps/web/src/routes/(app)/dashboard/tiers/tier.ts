import type { Term } from "$utils/term";
import type { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";

export type Tier = {
    localId: string;
    dTag?: string;
    name: string;
    description: string;
    amounts: Record<string, string>;
    image: string;
    modified?: boolean;
    deleted?: boolean;
};

export function amountsFromTier(tier: NDKEvent) {
    return tier.getMatchingTags("amount").reduce((acc, tag) => {
        console.log("tag123", tag);
        const currency = tag[2];
        let amount = tag[1];

        if (currency === "msat") {
            amount = (parseInt(amount) / 1000).toString();
        }

        acc[tag[3]] = amount;
        return acc;
    }, {} as Record<string, string>);
}

export function amountTag(amount: string, currency: string, term: Term) {
    const tag: NDKTag = ["amount"];

    if (currency === "msat") {
        tag.push((parseInt(amount) * 1000).toString(), "msat");
    } else {
        tag.push(amount, currency);
    }
    tag.push(term);

    return tag;
}