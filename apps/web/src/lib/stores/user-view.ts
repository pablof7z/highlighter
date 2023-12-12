import { ndk, user as currentUser } from "@kind0/ui-common";
import { NDKKind, NDKEvent, NDKArticle, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
import type { NDKUser, NDKFilter, Hexpubkey } from "@nostr-dev-kit/ndk";
import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
import { writable, get as getStore, derived, type Readable } from "svelte/store";
import { userActiveSubscriptions } from "./session";
import { getDefaultRelaySet } from "$utils/ndk";

export const activeUserViewPubkey = writable<Hexpubkey | undefined>(undefined);

export let userSubscription: NDKEventStore<NDKEvent> | undefined = undefined;
export const userTiers = writable<Readable<NDKArticle[]> | undefined>(undefined);
export const userContent = writable<Readable<NDKEvent[]> | undefined>(undefined);

export function startUserView(user: NDKUser) {
    const $ndk = getStore(ndk);
    const $userActiveSubscriptions = getStore(userActiveSubscriptions);
    const tier = $userActiveSubscriptions.get(user.pubkey) || "Free";
    const $currentUser = getStore(currentUser);
    const $activeUserViewPubkey = getStore(activeUserViewPubkey);

    console.log(`subscribing with tier ${tier} for user ${user.pubkey}`)

    if (userSubscription && $activeUserViewPubkey !== user.pubkey) {
        console.log(`unsubscribing from user ${$activeUserViewPubkey} to subscribe to ${user.pubkey}`);
        userSubscription.unsubscribe();
    }

    activeUserViewPubkey.set(user.pubkey);

    const filters: NDKFilter[] = [
        {
            kinds: [ NDKKind.Article ],
            authors: [user.pubkey],
            limit: 20
        },
        // supporting options
        {
            kinds: [ NDKKind.SubscriptionTier as number, NDKKind.TierList ],
            authors: [ user.pubkey ],
        },
        // supporters
        {
            kinds: [ NDKKind.SubscriptionStart as number ],
            "#p": [ user.pubkey ],
        },
        {
            kinds: [ 7003 as number ],
            "#P": [ user.pubkey ],
        },
        // zaps the user has received
        // {
        //     kinds: [ NDKKind.Zap ],
        //     "#p": [ user.pubkey ],
        //     limit: 20
        // }
    ];

    const groupFilter: NDKFilter = {
        "#h": [ user.pubkey ],
        "authors": [ user.pubkey ],

    }

    if (!$currentUser || $currentUser.pubkey !== user.pubkey) {
        groupFilter["#f"] = [ tier ];
    }

    filters.push(groupFilter);

    userSubscription = $ndk.storeSubscribe(filters, {
        subId: 'user-view',
        autoStart: true,
        groupable: false,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
        relaySet: getDefaultRelaySet()
    });

    userTiers.set(getUserSupportPlansStore());
    userContent.set(getUserContent());
}

export function getContent() {
    const $activeUserViewPubkey = getStore(activeUserViewPubkey);

    if (!userSubscription) return derived([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !$activeUserViewPubkey) return [];

        const groupContent = $userSubscription.filter((event: NDKEvent) => {
            return event.tagValue("h") === $activeUserViewPubkey;
        });

        return groupContent;
    });
}

export function getUserSupportPlansStore() {
    const $activeUserViewPubkey = getStore(activeUserViewPubkey);

    if (!userSubscription) return derived<[], NDKArticle[]>([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !$activeUserViewPubkey) return [];

        const tierList = $userSubscription.find((event: NDKEvent) => {
            return event.kind === NDKKind.TierList;
        });

        if (!tierList) return [];

        const tiers: NDKArticle[] = [];

        for (const tag of tierList.getMatchingTags("e")) {
            const tier = $userSubscription.find((event: NDKEvent) => {
                if (event.kind !== NDKKind.SubscriptionTier) return false;
                return event.id === tag[1];
            });

            if (!tier) {
                console.log(`could not find tier ${tag[1]}`);
            }

            if (tier) tiers.push(NDKArticle.from(tier));
        }

        return tiers;
    });
}

export function getUserSupporters(): Readable<NDKEvent[]> {
    const $activeUserViewPubkey = getStore(activeUserViewPubkey);

    if (!userSubscription) return derived([], () => []);

    return derived(userSubscription, ($userSubscription) => {
        if (!$userSubscription || !$activeUserViewPubkey) return [];

        const supporters = $userSubscription.filter((event: NDKEvent) => {
            const until = event.tagValue("until")
            if (!until) return false;
            const validUntil = new Date(parseInt(until) * 1000);
            return (
                event.kind === 7003 &&
                event.tagValue("P") === $activeUserViewPubkey &&
                validUntil > new Date()
            );
        });

        return supporters;
    });
}

export function getUserContent(): Readable<NDKEvent[]> {
    if (!userSubscription) return derived([], () => []);

    return derived(
        [userSubscription],
        ([$userSubscription]) => {
            const items = $userSubscription;
            const ids: string[] = items.map((event: NDKEvent) => event.tagId());

            // go through all the items, if there is an item that has a "full" tag with a value that exists in ids, remove it
            const filteredItems = items.filter((event: NDKEvent) => {
                const fullTag = event.tagValue("full");
                if (!fullTag) return true;

                return !ids.includes(fullTag);
            });

            return filteredItems;
        });

        // if (!$userSubscription || !activeUserView) return [];
        // return $userSubscription;

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

        // return items;
    // });
}