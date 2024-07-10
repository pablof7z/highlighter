import { Hexpubkey, NDKArticle, NDKKind, NDKList, NDKRelaySet, NDKTag, NDKVideo, eventIsReply, type NDKEvent } from '@nostr-dev-kit/ndk';
import { getDefaultRelaySet } from './ndk';
import { nip19 } from 'nostr-tools';
import { AddressPointer, EventPointer } from 'nostr-tools/nip19';
import { requiredTiersFor } from '$lib/events/tiers';
import createDebugger from 'debug';

const debug = createDebugger('HL:utils:event');

export const articleKinds = [
	NDKKind.Article,
	NDKKind.Wiki,
	NDKKind.ModularArticle,
	NDKKind.ModularArticleItem,
];

export const videoKinds = [
	NDKKind.HorizontalVideo,
	NDKKind.HorizontalVideo + 1,
];

export const mainContentKinds = [
	NDKKind.Article,
	NDKKind.HorizontalVideo,
	NDKKind.ArticleCurationSet,
	NDKKind.VideoCurationSet,
	NDKKind.Wiki,
];

export function encodeTag(tag: NDKTag) {
	const relay = tag[2];
	
	if (tag[0] === "a") {
		const [ kind, pubkey, identifier ] = tag[1].split(":");

		try {
			const opts: AddressPointer = {
				kind: parseInt(kind),
				pubkey: pubkey,
				identifier: identifier,
			};

			if (relay) opts.relays = [relay];
			
			return nip19.naddrEncode(opts);
		} catch {}
	} else if (tag[0] === "e") {
		try {
			const opts: EventPointer = {
				id: tag[1],
			}
			if (relay) opts.relays = [relay];
			return nip19.neventEncode(opts);
		} catch (e) {
			console.error(e);
		}
	}
}

export function eventToKind(event: NDKEvent) {
	switch (event.kind) {
		case 30818: return NDKArticle.from(event);
		case NDKKind.Article, 30040, 30041: return NDKArticle.from(event);
		case NDKKind.HorizontalVideo: return NDKVideo.from(event); 
		case NDKKind.ArticleCurationSet: return NDKList.from(event);
		case NDKKind.VideoCurationSet: return NDKList.from(event);
		default: return event;
	}
}

export function eventToSpecificKind(event: NDKEvent) {
	switch (event.kind) {
		case NDKKind.Article: return { article: NDKArticle.from(event) };
		case NDKKind.HorizontalVideo: return { video: NDKVideo.from(event) };
		case NDKKind.ArticleCurationSet: return { articleList: NDKList.from(event) };
	}

	return {};
}

const groupEvents = [
	NDKKind.GroupChat,
	NDKKind.GroupNote,
	NDKKind.GroupReply
];

export function relaySetForEvent(event: NDKEvent): NDKRelaySet | undefined {
	const d = debug.extend('relaySetForEvent');

	// if the event is kind 1, undefined
	if (event.kind === NDKKind.Text) return undefined;

	// if the event is a group event
	if (groupEvents.includes(event.kind!)) {
		return getDefaultRelaySet();
	}

	const hasHTag = !!event.tagValue('h');
	if (hasHTag) {
		const requiredTiers = requiredTiersFor(event);
		const doesNotHaveFree = !requiredTiers.includes('Free');

		if (doesNotHaveFree) {
			const relays = getDefaultRelaySet();
			d('Event kind:%d with required tiers:%o has no free tier, returning default relays:%o', event.kind, requiredTiers, relays);
			return relays;
		} else {
			d('Event kind:%d with required tiers:%o has free tier, returning undefined', event.kind, requiredTiers);
		}
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
		} catch {
			return false;
		}
	});

/**
 * Creates a function that returns true only if the event passed in is of a certain kind(s)
 * @returns 
 */
export const isKind = (n: NDKKind | NDKKind[]) => {
	if (Array.isArray(n)) {
		const set = new Set(n);
		return (e: NDKEvent) => set.has(e.kind!);
	} else 
		return (e: NDKEvent) => e.kind === n;
}

/**
 * Creates a function that returns unique pubkeys from a list of events
 * @param events 
 * @returns 
 */
export const uniquePubkeys = (events: NDKEvent[]) => {
	return Array.from(
		new Set(events.map((e: NDKEvent) => e.pubkey))
	)
}

export const prettifyReaction = (content: string) => {
	switch (content) {
		case "+": return "👍";
		case "-": return "👎";
		default:
			return content;
	}
}

export const isDirectReply = (op: NDKEvent) => (event: NDKEvent) => eventIsReply(op, event);

export function isEventFullVersion(event: NDKEvent) {
	// if the event has a "full" marker then this is not the full version
	if (!!event.tagValue("full")) return false;

	return true;
}

export function chronologically(a: NDKEvent, b: NDKEvent) {
	return a.created_at! - b.created_at!;
}