import type { NDKEvent } from '@nostr-dev-kit/ndk';

export const EVENT_ID_SUFFIX_LENGTH = 999;

const hostname = import.meta.env.VITE_HOSTNAME;

export function urlFromEvent(event: NDKEvent, authorUrl?: string): string {
	const suffix = urlSuffixFromEvent(event);
	let id = `/${event.author.npub}`;

	if (authorUrl) {
		id = authorUrl;
	}

	return `https://${hostname}${authorUrl}/${suffix}`;
}

export function urlSuffixFromEvent(event: NDKEvent): string {
	if (event.isParamReplaceable() && event.tagValue('d')) {
		return encodeURIComponent(event.tagValue('d')!);
	}

	return event.encode();
}

export function urlSuffixFromTagId(tagId: string): string {
	const dTag = tagId.split(':')[2];

	if (dTag) {
		return dTag;
	}

	return tagId;
}
