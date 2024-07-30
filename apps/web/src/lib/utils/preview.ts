import truncateMarkdown from 'markdown-truncate';
import { NDKArticle } from "@nostr-dev-kit/ndk";

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