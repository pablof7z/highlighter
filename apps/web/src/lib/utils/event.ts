import NDK, { NDKKind, type NDKEvent } from '@nostr-dev-kit/ndk';

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
