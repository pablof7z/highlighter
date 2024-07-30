import { writable } from 'svelte/store';
import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';

export const ndkRelaysWithAuth = persist(
    writable<Map<string, boolean | ((value: boolean) => void)>>(new Map()),
    createLocalStorage(), 'ndk.relays-with-auth'
);

