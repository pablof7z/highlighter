import { LoginMethod } from "$utils/login";
import { createLocalStorage, persist } from "@macfja/svelte-persistent-store";
import { NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
import { derived, writable } from "svelte/store";
import { variableStore } from 'svelte-capacitor-store';

const currentUser = writable<NDKUser | undefined>(undefined);
export const loginMethod = persist(
    writable<LoginMethod | undefined>(undefined),
    createLocalStorage(),
    "nostr-key-method"
);

export const userPubkey = variableStore<string | null>({
    storeName: 'user-pubkey',
    initialValue: null,
    persist: true,
    browserStorage: 'localStorage',
    validationStatement: (value) => {
        if (!value) return true;
        try {
            const user = new NDKUser({pubkey: value});
            return !!user.npub;
        } catch {
            return false;
        }
    }
});

export const isGuest = derived(loginMethod, $loginMethod => $loginMethod === "guest");

export const privateKey = variableStore<string | undefined>({
    storeName: 'private-key',
    initialValue: undefined,
    persist: true,
    browserStorage: 'localStorage',
    validationStatement: (value) => {
        if (!value) return true;
        try {
            const pk = new NDKPrivateKeySigner(value);
            return true;
        } catch {
            return false;
        }
    }
});

export default currentUser;