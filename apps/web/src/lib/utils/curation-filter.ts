import { userFollows } from "$stores/session";
import { NDKList } from "@nostr-dev-kit/ndk";
import { derived, Readable } from "svelte/store";
import { blacklistedPubkeysSet } from "./const";

const filterList = (removeNoDescription: boolean) => (list: NDKList) => {
    if (blacklistedPubkeysSet.has(list.pubkey)) return false;
    
    // if it doesn't have items
    if (!list.items || list.items.length === 0) return false;
    
    // If the title starts with "News", we don't want to show it
    if (list.title?.startsWith('News')) return false;

    // If it doesn't have an image
    if (!list.image) return false;

    // if it doesn't have a title
    if (!list.title || list.title === "undefined") return false;
    if (list.title === 'To read') return false;

    // test doesn't say "test"
    if (list.title.toLowerCase().includes("test")) return false;

    if (removeNoDescription) {
        if (!list.description) return false;
    }

    return true;
}

export function filterLists(
    list: Readable<NDKList[]>,
    minWordCount: number = 400,
    removeNoDescription = true
): Readable<NDKList[]> {
    return derived([list, userFollows], ([$list, $userFollows]) => {
        let ret = $list.filter(filterList(removeNoDescription));

        // strongly prefer to show list from the user's follows
        // but lower the preference the older the published_at is
        function listScore(list: NDKList) {
            const followed = $userFollows.has(list.pubkey);
            const age = Date.now() - ((list.created_at!) * 1000);
            const oneWeek = 1000 * 60 * 60 * 24 * 7;
            return followed ? oneWeek - age : 0 - age;
        }

        const scores: Record<string, number> = {};
        ret.forEach((list) => {
            scores[list.id] = listScore(list);
        });
        
        return ret.sort((a, b) => {
            const aScore = scores[a.id];
            const bScore = scores[b.id];

            if (aScore > bScore) return -1;
            if (aScore < bScore) return 1;
            return 0;
        });
    });
}