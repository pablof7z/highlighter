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

export function readTime(content: string): string {
	const words = countWords(content);
	const minutes = Math.ceil(words / 200);

	if (minutes < 1) {
		return '1 min';
	}

	// convert minutes to hours
	if (minutes > 60) {
		const hours = Math.floor(minutes / 60);
		const remainingMinutes = minutes % 60;
		return `${hours} hour`;
	} else  {
		return `${minutes} min`;
	}
}