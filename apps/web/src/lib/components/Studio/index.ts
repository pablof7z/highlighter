import { Writable } from "svelte/store";
import Root from "./Root.svelte";
import Shell from "./Shell.svelte";
import { NDKEventId, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";

enum Types {
    Article = "article",
    Video = "video",
    Thread = "thread"
}

export type Mode = "view" | "edit" | "audience" | "preview" | "publish";
export type Scope = "public" | "private";
export type GroupId = string;
export type Relays = string[];
export type PublishInGroupStore = Writable<Map<GroupId, Relays>>;

/**
 * A map of SubscriptionTier's d-tags and the event.
 * 
 * We don't care about to which community the subscription is from, since
 * they will all be dumped as [ "tier", "d-tag" ] in the tags anyway.
 */
export type PublishInTierStore = Writable<Map<string, NDKSubscriptionTier>>;

export {
    Root,
    Shell,
    Types
}