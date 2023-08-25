import { persist, createLocalStorage } from "@macfja/svelte-persistent-store";
import { writable, get as getStore } from "svelte/store";

export const addJobButtonsSeen = persist(
    writable<number>(0),
    createLocalStorage(),
    "add-job-buttons-seen",
);