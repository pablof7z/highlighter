import type { TierSelection } from "$lib/events/tiers";
import { Thread } from "$utils/thread";
import { NDKArticle, NDKEvent, NDKVideo } from "@nostr-dev-kit/ndk";
import { writable } from "svelte/store";
import { DraftItem } from "./drafts";

export type View = "edit" | "audience" | "view-preview" | "edit-preview" | "preview" | "publish" | "distribution" | "meta" | "published";

export const selectedTiers = writable<TierSelection>({})
export const view = writable<View>("edit");
export const type = writable<"article" | "video" | "thread" | null>(null);
export const event = writable<NDKArticle | NDKVideo | NDKEvent | Thread | null>(null);
export const preview = writable<NDKArticle | NDKVideo | NDKEvent | false | undefined>(undefined);
export const currentDraftItem = writable<DraftItem | undefined>(undefined);
export const nonSubscribersPreview = writable<boolean | undefined>(undefined);
export const makePublicAfter = writable<number | false | undefined>(undefined);
export const previewExtraContent = writable<{before: string|undefined, after: string|undefined} | undefined>();
export const publishAt = writable<Date | undefined>(undefined);
export const status = writable<string[]>([]);

export const previewTitleChanged = writable<boolean>(false);
export const previewContentChanged = writable<boolean>(false);

export function reset(newView: View = "edit") {
    selectedTiers.set({});
    view.set(newView);
    type.set(null);
    event.set(null);
    preview.set(undefined);
    nonSubscribersPreview.set(undefined);
    makePublicAfter.set(undefined);
    publishAt.set(undefined);
    status.set([]);
}