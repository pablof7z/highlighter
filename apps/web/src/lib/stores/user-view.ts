import { ndk } from "@kind0/ui-common";
import { NDKKind, NDKEvent, type NDKUser, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
import { writable, get as getStore, derived, type Readable } from "svelte/store";

let activeUserView: NDKUser | undefined;

export let userSubscription: NDKEventStore<NDKEvent> | undefined = undefined;
export const userHighlights = writable(new Set<NDKEvent>);

export function startUserView(user: NDKUser) {
    const $ndk = getStore(ndk);

    if (userSubscription) {
        userSubscription.unsubscribe();
    }

    activeUserView = user;

    userSubscription = $ndk.storeSubscribe([
        // highlights and articles the user has created
        {
            kinds: [ NDKKind.Highlight, NDKKind.Article ],
            authors: [user.pubkey]
        },
        {
            kinds: [ NDKKind.Text ],
            authors: [user.pubkey],
            limit: 200
        },
        // supporting options
        {
            kinds: [ 37001 as number ],
            authors: [ user.pubkey ],
        },
        // supporters
        {
            kinds: [ 7001 as number ],
            "#p": [ user.pubkey ],
        },
        // zaps the user has received
        {
            kinds: [ NDKKind.Zap ],
            "#p": [ user.pubkey ]
        }
    ], {
        subId: 'user-view',
        autoStart: true,
        groupable: false,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });
}

export function getUserSupportPlansStore() {
    if (!userSubscription) return derived([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !activeUserView) return [];

        const plans = $userSubscription.filter((event: NDKEvent) => {
            return event.kind === 37001;
        });

        return plans;
    });
}

export function getUserSupporters(): Readable<NDKEvent[]> {
    if (!userSubscription) return derived([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !activeUserView) return [];

        const supporters = $userSubscription.filter((event: NDKEvent) => {
            return event.kind === 7001 && event.tagValue("p") === activeUserView?.pubkey;
        });

        return supporters;
    });
}

export function getUserContent(): Readable<NDKEvent[]> {
    if (!userSubscription) return derived([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !activeUserView) return [];

        const highlights = $userSubscription.filter((event: NDKEvent) => {
            return event.kind === NDKKind.Article;
        });

        return highlights;
    });
}