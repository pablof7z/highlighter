import { createLocalStorage, persist } from "@macfja/svelte-persistent-store";
import { writable } from "svelte/store";

type Mode = "all" | "paid";

export const mode = persist(
    writable<Mode>("paid"),
    createLocalStorage(true),
    "inbox-mode"
)