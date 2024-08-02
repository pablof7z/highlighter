import { ndk } from "$stores/ndk";
import { NDKUserProfile, Hexpubkey, NDKFilter, profileFromEvent, NDKEvent } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import createDebug from 'debug';

const d = createDebug('HL:profile-refresh');

const alreadyRefreshed: Set<Hexpubkey> = new Set();

/**
 * A map of profiles where the value is the 
 */
type ProfileRefreshEntry = {
    currentCreatedAt?: number;
    lastCheckedAt?: number;
    cb?: (profile: NDKUserProfile) => void;
}
export const profilesToRefresh: Map<Hexpubkey, ProfileRefreshEntry> = new Map();
export let refreshTimeout: number | NodeJS.Timeout | null = null;

const REFRESH_TIMER = 1000 * 30;

export function refresh(
    pubkey: Hexpubkey,
    profile: NDKUserProfile,
    onNewProfile?: (profile: NDKUserProfile, event: NDKEvent) => void
) {
    if (profilesToRefresh.has(pubkey)) return;

    if (alreadyRefreshed.has(pubkey)) {
        d("Already refreshed %s", pubkey);
        return;
    }

    d("Refresh profile scheduled %s", pubkey);
    
    profilesToRefresh.set(pubkey, {
        currentCreatedAt: profile.created_at,
        cb: onNewProfile
    })

    if (profilesToRefresh.size >= 10) {
        execute();
    } else {
        if (refreshTimeout) clearTimeout(refreshTimeout);

        refreshTimeout = setTimeout(execute, REFRESH_TIMER);
    }
}

export function execute() {
    const $ndk = get(ndk);
    let filters: NDKFilter[] = [];

    d("Executing profile refresh", profilesToRefresh.size);

    const now = Math.floor(Date.now() / 1000);

    profilesToRefresh.forEach((entry, pubkey) => {
        d("entry %o %o", entry, {pubkey});
        if (!pubkey) return;
        const filter: NDKFilter = { authors: [pubkey], kinds: [0] };
        if (entry.currentCreatedAt) {
            filter.since = entry.currentCreatedAt + 1;

            d("Time ago %d", now - entry.currentCreatedAt);
        }

        filters.push(filter);
        alreadyRefreshed.add(pubkey);
    });
    profilesToRefresh.clear();

    d("Profile refresh filters %o", filters);

    const results = new Map<Hexpubkey, NDKEvent>();

    // remove filters with empty authors
    filters = filters.filter(f => f.authors && f.authors.length > 0);
    if (filters.length === 0) {
        d("No profiles to refresh");
        return;
    }

    const sub = $ndk.subscribe(
        filters,
        { subId: 'profile-refresh', closeOnEose: true, groupable: false },
        undefined, false
    );
    sub.on("event", (event) => {
        const current = results.get(event.pubkey);
        if (current && current.created_at! >= event.created_at!)
            return;
    });

    sub.on("eose", () => {
        for (const [pubkey, event] of results) {
            const entry = profilesToRefresh.get(pubkey);
            const profile = profileFromEvent(event);

            if (entry?.cb) {
                d("Calling profile refresh callback %s", pubkey);
                entry.cb(profile);
            }
            d("Profile refreshed %s", pubkey);

            // update cache
            if (profile && $ndk.cacheAdapter && $ndk.cacheAdapter.saveProfile) {
                $ndk.cacheAdapter.saveProfile(pubkey, profile);
            }
        }
    });

    sub.on("close", () => {
        d("Profile refresh subscription closed");
    })

    sub.start();
}