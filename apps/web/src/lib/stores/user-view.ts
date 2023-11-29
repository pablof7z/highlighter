import { ndk } from "@kind0/ui-common";
import { NDKKind, NDKEvent, type NDKUser, NDKSubscriptionCacheUsage, NDKArticle } from "@nostr-dev-kit/ndk";
import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
import { writable, get as getStore, derived, type Readable } from "svelte/store";
import { userActiveSubscriptions } from "./session";

let activeUserView: NDKUser | undefined;

export let userSubscription: NDKEventStore<NDKEvent> | undefined = undefined;
export const userHighlights = writable(new Set<NDKEvent>);
export const userTiers = writable<Readable<NDKArticle[]> | undefined>(undefined);
export const userContent = writable<Readable<NDKEvent[]> | undefined>(undefined);

export function startUserView(user: NDKUser) {
    const $ndk = getStore(ndk);
    const $userActiveSubscriptions = getStore(userActiveSubscriptions);
    const tier = $userActiveSubscriptions.get(user.pubkey) || "Free";

    if (userSubscription) {
        userSubscription.unsubscribe();
    }

    activeUserView = user;

    userSubscription = $ndk.storeSubscribe([
        {
            kinds: [ NDKKind.Article ],
            authors: [user.pubkey],
            limit: 50
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
            "#p": [ user.pubkey ],
            limit: 20
        },
        // get group content published by the user
        {
            "#h": [ user.pubkey ],
            "authors": [ user.pubkey ],
            "#f": [ tier ]
        }
    ], {
        subId: 'user-view',
        autoStart: true,
        groupable: false,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });

    userTiers.set(getUserSupportPlansStore());
    userContent.set(getUserContent());
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

    return derived(
        [userSubscription],
        ([$userSubscription]) => {
        if (!$userSubscription || !activeUserView) return [];
        return $userSubscription;

        // const items = $userSubscription.filter((event: NDKEvent) => {
        //     return event.tagValue("h") === activeUserView!.pubkey;
        // });

        // if we have any active subscriptions, filter out any content that is not
        // from the active subscriptions
        // const subscribed = $userActiveSubscriptions.get(activeUserView.pubkey) !== "Free";
        // if (subscribed) {
        //     // find the item that belongs to this active subscription
        //     const rightItems = items.filter((event: NDKEvent) => {
        //     return items.filter((event: NDKEvent) => {
        //         return $userActiveSubscriptions.get(event.author) !== "Free";
        //     });
        // }

        return items;
    });
}