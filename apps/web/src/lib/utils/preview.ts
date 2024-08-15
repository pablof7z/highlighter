import truncateMarkdown from 'markdown-truncate';
import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";

export function generatePreviewContent(
    article: NDKArticle
) {
    let limit = Math.min(1000, article.content.length * 0.4);
    if (limit > 2000) limit = 2000;
    let previewContent = truncateMarkdown(article.content, {
        limit,
        ellipsis: true
    });
    previewContent ??= "";

    return previewContent;
}

export function eventIsPreview(
    event: NDKEvent
) {
    return !!event.tagValue("full")
}

export function eventIsPaid(
    event: NDKEvent
) {
    let isPaidOnly = false;
    
    if (event) {
        const hasFree = event.getMatchingTags("f").some(t => t[1] === "Free");
        isPaidOnly = !hasFree && event.hasTag("f");
    }

    return isPaidOnly;
}

export function eventIsInGroup(
    event: NDKEvent
) {
    return event.hasTag("h");
}