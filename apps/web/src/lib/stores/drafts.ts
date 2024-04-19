import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { writable } from 'svelte/store';
import type { EventType } from '../../app';
import type { TierSelection } from '$lib/events/tiers';
import { NDKEventSerialized } from '@nostr-dev-kit/ndk';

export type ArticleCheckpoint = {
	article: string;
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
	time: number;
	data: CheckpointData;
	manuallySaved: boolean;
};

export type DraftItem = {
	type: EventType | 'thread';
	id: string;
	checkpoints: string;
};

export const drafts = persist(writable<DraftItem[]>([]), createLocalStorage(true), 'drafts');
