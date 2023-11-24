import { ndk } from "@kind0/ui-common";
import { NDKKind, NDKEvent, type NDKUser, NDKSubscriptionCacheUsage, NDKArticle } from "@nostr-dev-kit/ndk";
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
        },
        // get group content published by the user
        {
            "#h": [ user.pubkey ],
            "authors": [ user.pubkey ],
        }
    ], {
        subId: 'user-view',
        autoStart: true,
        groupable: false,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });
}

export function getContent() {
    if (!userSubscription) return derived([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !activeUserView) return [];

        const groupContent = $userSubscription.filter((event: NDKEvent) => {
            return event.tagValue("h") === activeUserView?.pubkey;
        });

        return groupContent;
    });
}

export function getUserSupportPlansStore() {
    if (!userSubscription) return derived<[], NDKArticle[]>([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !activeUserView) return [];

        const plans = $userSubscription.filter((event: NDKEvent) => {
            return event.kind === 37001;
        }).map((event: NDKEvent) => {
            return NDKArticle.from(event);
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