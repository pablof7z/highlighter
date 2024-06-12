import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { writable } from 'svelte/store';
import type { TierSelection } from '$lib/events/tiers';
import { NDKEventSerialized } from '@nostr-dev-kit/ndk';

export type ArticleCheckpoint = {
	event: string;
	preview: string;
	tiers?: TierSelection;
};

export type ThreadCheckpointItem = {
	event: NDKEventSerialized;
	urls: string[];
};

export type ThreadCheckpoint = {
	items: ThreadCheckpointItem[];
}

export type CheckpointData = ArticleCheckpoint | ThreadCheckpoint;

export type DraftCheckpoint = {
	/**
	 * If the event has been fetched from a NIP-37 event.
	 */
	eventId?: string;

	/**
	 * If the event has been fetched from a NIP-37 event.
	 */
	relay?: string;

	time: number;
	data: CheckpointData;
	manuallySaved: boolean;
};

export type DraftItemType = "article" | "video" | 'thread';

export type DraftItem = {
	type: DraftItemType
	id: string;
	checkpoints: string;
};

export const drafts = persist(writable<DraftItem[]>([]), createLocalStorage(true), 'drafts');

export function initializeDrafts() {

}