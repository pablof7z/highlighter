import { writable } from "svelte/store";

export const activeSelection = writable<Selection | null>(null);