import { Hexpubkey, NDKKind, NDKRelaySet, NDKTag, type NDKEvent } from '@nostr-dev-kit/ndk';
import { getDefaultRelaySet } from './ndk';
import { nip19 } from 'nostr-tools';

/**
 * Checks whether the event is a root event.
 */
export function isRootEvent(event: NDKEvent): boolean {
	return !event.tagValue('e');
}

export const mainContentKinds = [
	NDKKind.Article,
	NDKKind.HorizontalVideo,
	NDKKind.ArticleCurationSet,
	NDKKind.VideoCurationSet
];

export function relaySetForEvent(event: NDKEvent): NDKRelaySet | undefined {
	// if the event is kind 1, undefined
	if (event.kind === NDKKind.Text) return undefined;

	// if the event has an h tag then default relay
	if (event.tagValue('h')) {
		return getDefaultRelaySet();
	}

	return undefined;
}

export const filterValidPTags = (tags: NDKTag[]) => tags
	.filter((t: NDKTag) => t[0] === 'p')
	.map((t: NDKTag) => t[1])
	.filter((f: Hexpubkey) => {
		try {
			nip19.npubEncode(f);
			return true;
		} catch { return false; }
	});