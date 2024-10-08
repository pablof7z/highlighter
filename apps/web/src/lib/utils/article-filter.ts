import { userFollows } from "$stores/session";
import { NDKArticle } from "@nostr-dev-kit/ndk";
import { Readable, derived, get } from "svelte/store";
import { blacklistedPubkeys, blacklistedPubkeysSet } from "./const";

export function filterArticle(
    article: NDKArticle,
    minWordCount: number = 1,
    removeTest = true
) {
    // If the title starts with "News", we don't want to show it
    if (article.title?.startsWith('News')) return false;

    // If it doesn't have an image
    if (!article.image) return false;

    if (removeTest) {
        if (article.title?.match(/test/i)) return false;
    }

    // if it doesn't have a title
    if (!article.title || article.title === "undefined") return false;

    const wordCount = article.content.split(/ /).length;
    if (wordCount < minWordCount) {
        return false;
    }

    for (const tag of article.getMatchingTags("t")) {
        // If the article has the tag nostrcooking, we don't want to show it
        if (tag[1]?.startsWith('nostrcooking')) return false;
    }

    return true;
}

export function filterPreviewArticles(
    articles: Readable<NDKArticle[]>
) {
    return derived(articles, ($articles) => {
        // go through the articles and note the tagId
        const articlesTagIds = new Set<string>();
        $articles.forEach(a => articlesTagIds.add(a.tagId()));

        const noPreviewOfFullArticles = (article: NDKArticle) => {
            const full = article.tagValue("full");
            const doesntHaveFull = !full;
        
            if (doesntHaveFull) return true;
        
            const fullVersionIsNotPresent = !articlesTagIds.has(full);
            if (fullVersionIsNotPresent) return true;
        }

        return $articles.filter(noPreviewOfFullArticles);
    });
}

export function filterArticles(
    articles: Readable<NDKArticle[]>,
    minWordCount: number = 10,
    removeTest = true
): Readable<NDKArticle[]> {
    return derived([articles, userFollows], ([$articles, $userFollows]) => {
        let ret = $articles.filter((article) => {
            // if it's followed by the user, we want to show it
            // if ($userFollows.has(article.pubkey)) return true;
            if (blacklistedPubkeysSet.has(article.pubkey)) return false;

            return filterArticle(article, minWordCount, removeTest);
        });

        // strongly prefer to show articles from the user's follows
        // but lower the preference the older the published_at is
        function articleScore(article: NDKArticle) {
            const followed = $userFollows.has(article.pubkey);
            const age = Date.now() - ((article.published_at ?? article.created_at!) * 1000);
            const oneWeek = 1000 * 60 * 60 * 24 * 7;
            return followed ? oneWeek - age : 0 - age;
        }

        const scores: Record<string, number> = {};
        ret.forEach((article) => {
            scores[article.id] = articleScore(article);
        });

        // return ret;
        
        return ret.sort((a, b) => {
            const aScore = scores[a.id];
            const bScore = scores[b.id];

            if (aScore > bScore) return -1;
            if (aScore < bScore) return 1;
            return 0;
        });
    });
}