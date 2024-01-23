import type { NDKEvent } from '@nostr-dev-kit/ndk';

export const EVENT_ID_SUFFIX_LENGTH = 18;

export function urlFromEvent(event: NDKEvent): string {
	const suffix = urlSuffixFromEvent(event);
	const npub = event.author.npub;

	return `https://highlighter.com/${npub}/${suffix}`;
}

export function urlSuffixFromEvent(event: NDKEvent): string {
	if (event.isParamReplaceable() && event.tagValue('d')) {
		return event.tagValue('d')!;
	}

	return event.id.slice(0, EVENT_ID_SUFFIX_LENGTH);
}

export function urlSuffixFromTagId(tagId: string): string {
	const dTag = tagId.split(':')[2];

	if (dTag) {
		return dTag;
	}

	return tagId.slice(0, EVENT_ID_SUFFIX_LENGTH);
}
