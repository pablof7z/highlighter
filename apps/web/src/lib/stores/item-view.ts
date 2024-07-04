import { NDKArticle, NDKEvent, NDKList, NDKSimpleGroup, NDKVideo } from "@nostr-dev-kit/ndk";
import { writable } from "svelte/store";

export const loadedEvent = writable<NDKEvent | NDKArticle | NDKVideo | NDKList | null | undefined>(null);
export const title = writable<string | undefined>(undefined);

export const loadedGroup = writable<NDKSimpleGroup | null | undefined>(null);
export const groupView = writable<{
    isMember: boolean | undefined;
    isAdmin: boolean | undefined;
}>({
    isMember: undefined,
    isAdmin: undefined,
});