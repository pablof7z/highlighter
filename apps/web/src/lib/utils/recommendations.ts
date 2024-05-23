import { NDKEvent, NDKHighlight, NDKTag } from "@nostr-dev-kit/ndk";
import { Readable, derived } from "svelte/store";

function computeArticleScore(highlights: NDKHighlight[]): number {
    // compute the score such that the more different pubkeys are involved, the higher the score
    // and the more recent (created_at) the highlights are, the higher the score
    // also the more highlights there are, the higher the score
    let score = 0;
    const pubkeys = new Set<string>();

    const threeDaysAgo = (new Date().getTime() - 3 * 24 * 60 * 60 * 1000) / 1000;
    
    highlights = highlights.filter(h => h.created_at! > threeDaysAgo);

    // count the number of different pubkeys
    highlights.forEach((highlight) => pubkeys.add(highlight.pubkey) );

    // compute the score of each highlight
    highlights.forEach((highlight) => {
        score += 0.1;
    });

    score += pubkeys.size * 0.5;

    return score;
}

export function computeArticleRecommendationFromHighlightStore(
    highlights: Readable<NDKEvent[]>
): Readable<{tag: NDKTag, highlights: NDKHighlight[]}[]> {
    return derived(highlights, ($highlights) => {
        const startTime = new Date().getTime();
        const highlightsByArticle = new Map<string, NDKHighlight[]>();
        const articles = new Map<string, number>();
        const articleIdToTag = new Map<string, NDKTag>();

        // group highlights by article
        $highlights.forEach((event) => {
            const highlight = NDKHighlight.from(event);
            const articleTag = highlight.getArticleTag();
            if (!articleTag) return;

            const articleId = articleTag[0] + articleTag[1];
            if (!articleIdToTag.has(articleId)) {
                articleIdToTag.set(articleId, articleTag);
            }
            
            const highlights = highlightsByArticle.get(articleId) || [];
            highlights.push(highlight);
            highlightsByArticle.set(articleId, highlights);
        });

        // compute articles score
        highlightsByArticle.forEach((highlights, articleId) => {
            const score = computeArticleScore(highlights);
            articles.set(articleId, score);
        });

        const sortedArticles = Array.from(articles.entries()).sort(
            (a, b) => b[1] - a[1]
        ).map(([articleId]) => articleId);

        const res = sortedArticles.map((articleId) => {
            const tag = articleIdToTag.get(articleId);
            return { tag: tag!, highlights: highlightsByArticle.get(articleId)! };
        });

        const endTime = new Date().getTime();
        // console.log("computeArticleRecommendationFromHighlightStore took", endTime - startTime, "ms");
        
        return res;
    });
}