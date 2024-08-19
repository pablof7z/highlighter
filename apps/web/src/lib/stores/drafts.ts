import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { writable } from 'svelte/store';

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
	data: string;
	manuallySaved: boolean;

	/**
	 * Random checkpoint id
	 */
	id: string;
};

export type DraftItemType = "article" | "video" | 'thread' | "studio" | "composer";

export type DraftItem = {
	type: DraftItemType
	id: string;
	checkpoints: DraftCheckpoint[];
};

export const drafts = persist(writable<DraftItem[]>([]), createLocalStorage(true), 'drafts');

export function initializeDrafts() {

}