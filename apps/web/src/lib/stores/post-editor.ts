import type { TierSelection } from "$lib/events/tiers";
import { NDKArticle, NDKEvent, NDKVideo } from "@nostr-dev-kit/ndk";
import { writable } from "svelte/store";

export const selectedTiers = writable<TierSelection>({})
export const view = writable<"edit" | "preview" | "distribution" | "meta" | "schedule" | "publish" | "published">("edit");
export const type = writable<"article" | "video" | "note" | null>(null);
export const event = writable<NDKArticle | NDKVideo | NDKEvent | null>(null);
export const preview = writable<NDKArticle | NDKVideo | NDKEvent | false | undefined>(undefined);
export const nonSubscribersPreview = writable<boolean | undefined>(undefined);
export const makePublicAfter = writable<number | false | undefined>(undefined);
export const wideDistribution = writable<boolean | undefined>(undefined);
export const publishAt = writable<Date | undefined>(undefined);

export const previewTitleChanged = writable<boolean>(false);
export const previewContentChanged = writable<boolean>(false);