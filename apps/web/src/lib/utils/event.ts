import { Hexpubkey, NDKArticle, NDKKind, NDKList, NDKRelaySet, NDKTag, NDKVideo, type NDKEvent } from '@nostr-dev-kit/ndk';
import { getDefaultRelaySet } from './ndk';
import { nip19 } from 'nostr-tools';

export const mainContentKinds = [
	NDKKind.Article,
	NDKKind.HorizontalVideo,
	NDKKind.ArticleCurationSet,
	NDKKind.VideoCurationSet
];

export function eventToSpecificKind(event: NDKEvent) {
	switch (event.kind) {
		case NDKKind.Article: return { article: NDKArticle.from(event) };
		case NDKKind.HorizontalVideo: return { video: NDKVideo.from(event) };
		case NDKKind.ArticleCurationSet: return { articleList: NDKList.from(event) };
	}

	return {};
}

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