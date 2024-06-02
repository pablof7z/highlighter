import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
import { writable } from "svelte/store";

export const loadedEvent = writable<NDKEvent | NDKArticle | NDKVideo | NDKList | null | undefined>(null);
export const title = writable<string | undefined>(undefined);