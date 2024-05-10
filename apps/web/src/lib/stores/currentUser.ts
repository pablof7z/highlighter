import { LoginMethod } from "$utils/login";
import { createLocalStorage, persist } from "@macfja/svelte-persistent-store";
import { NDKUser } from "@nostr-dev-kit/ndk";
import { derived, writable } from "svelte/store";

const currentUser = writable<NDKUser | undefined>(undefined);
export const loginMethod = persist(
    writable<LoginMethod | undefined>(undefined),
    createLocalStorage(),
    "nostr-key-method"
);

export const userPubkey = persist(
    writable<string | undefined>(undefined),
    createLocalStorage(),
    "pubkey"
);

export const isGuest = derived(loginMethod, $loginMethod => $loginMethod === "guest");

export const privateKey = persist(
    writable<string | undefined>(undefined),
    createLocalStorage(),
    "pk"
);

export default currentUser;