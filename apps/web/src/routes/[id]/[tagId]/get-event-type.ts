import { type NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
import type { EventType } from '../../../app';

export function getEventType(event: NDKEvent): EventType | undefined {
	if (event.kind === NDKKind.Article) {
		return 'article';
	} else if (event.kind === NDKKind.HorizontalVideo) {
		return 'video';
	} else if (event.kind === NDKKind.GroupNote) {
		return 'group-note';
	} else if (event.kind === NDKKind.Text) {
		return 'short-note';
	} else if (event.kind === NDKKind.Highlight) {
		return 'highlight';
	} else if ([
		NDKKind.ArticleCurationSet,
		NDKKind.VideoCurationSet,
		NDKKind.BookmarkSet,
	].includes(event.kind!)) {
		return 'curation';
	} else {
		console.trace('Unknown event type', event.rawEvent());
	}

	return undefined;
}
