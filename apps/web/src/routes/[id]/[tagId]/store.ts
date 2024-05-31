import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
import { writable } from "svelte/store";

export const loadedEvent = writable<NDKEvent | NDKArticle | null>(null);
export const title = writable<string | undefined>(undefined);