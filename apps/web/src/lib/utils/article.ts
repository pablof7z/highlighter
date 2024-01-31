import type { NDKArticle } from '@nostr-dev-kit/ndk';
import truncateMarkdown from 'markdown-truncate';

export function getSummary(article: NDKArticle) {
	let summary = article.summary;

	if (!summary) {
		const limit = Math.min(150, article.content.length * 0.4);
		summary = truncateMarkdown(article.content, {
			limit,
			ellipsis: true
		});
	}

	return summary;
}


export function countWords(content: string) {
	return content.split(/\s+/).length;
}