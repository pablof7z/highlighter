import type { NDKArticle } from '@nostr-dev-kit/ndk';
import truncateMarkdown from 'markdown-truncate';
import { Readable } from 'svelte/store';

export function getSummary(article: NDKArticle, force = false) {
	let summary = article.summary;

	if (force && (!summary || summary.length < 10)) {
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
