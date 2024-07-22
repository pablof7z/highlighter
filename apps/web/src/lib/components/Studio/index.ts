import { Writable } from "svelte/store";
import Root from "./Root.svelte";
import Shell from "./Shell.svelte";

enum Types {
    Article = "article",
    Video = "video",
    Thread = "thread"
}

export type Mode = "view" | "edit" | "audience" | "preview";
export type GroupId = string;
export type Relays = string[];
export type PublishInGroupStore = Writable<Map<GroupId, Relays>>

export {
    Root,
    Shell,
    Types
}