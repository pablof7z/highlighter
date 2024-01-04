import { persist, createLocalStorage } from "@macfja/svelte-persistent-store";
import { writable } from "svelte/store";
import type { EventType } from "../../app";
import type { TierSelection } from "$lib/events/tiers";

export type ArticleCheckpoint = {
    article: string,
    preview: string,
    tiers: TierSelection
}

export type CheckpointData = ArticleCheckpoint;

export type DraftCheckpoint = {
    time: number,
    data: CheckpointData,
    manuallySaved: boolean,
};

export type DraftItem = {
    type: EventType,
    id: string,
    checkpoints: string,
}

export const drafts = persist(
    writable<DraftItem[]>([]),
    createLocalStorage(true),
    "drafts"
);