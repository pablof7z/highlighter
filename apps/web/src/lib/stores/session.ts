import { writable, get as getStore, type Writable, derived, get } from 'svelte/store';
import { ndk, user } from '@kind0/ui-common';
import {
	NDKEvent,
	NDKList,
	NDKSubscriptionCacheUsage,
	type NDKFilter,
	type NDKTag,
	NDKKind,
	NDKListKinds,
	type Hexpubkey,
	profileFromEvent,
	NDKSubscriptionTier,
	NDKRelaySet,
	NostrEvent,
} from '@nostr-dev-kit/ndk';
import type NDKSvelte from '@nostr-dev-kit/ndk-svelte';
import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import debug from 'debug';
import type { UserProfileType } from '../../app';
import { getDefaultRelaySet } from '$utils/ndk';
import { creatorRelayPubkey } from '$utils/const';
import { nip19 } from 'nostr-tools';

const d = debug('HL:session');
const $ndk = getStore(ndk);

export const jwt = persist(writable<string | null>(null), createLocalStorage(), 'jwt');

export const userProfile = writable<UserProfileType | undefined>(undefined);

export type LoginState = 'logging-in' | 'logged-in' | 'contacting-remote-signer' | 'logged-out';

export const loginState = writable<LoginState | null>(null);

export const debugMode = writable<boolean>(false);
export const debugPageFilter = writable<string | null>(null);

export const loadingScreen = writable<boolean>(false);

/**
 * Current user's follows
 */
export const userFollows = persist(
	writable<Set<string>>(new Set()),
	createLocalStorage(),
	'user-follows'
);

export const allUserTiers = writable<NDKSubscriptionTier[]>([]);
export const tierList = writable<NDKList|undefined>(undefined);
export const userTiers = derived(
	[allUserTiers, tierList],
	([$allUserTiers, $tierList]) => {
		const tiers: NDKSubscriptionTier[] = [];
		if (!tierList || !$tierList) return tiers;

		for (const tag of $tierList.getMatchingTags("e")) {
			const id = tag[1];

			for (const tier of $allUserTiers) {
				if (tier.id !== id) continue;
				if (tier.isValid) {
					tiers.push(tier);
				}
			}
		}

		d(`return # ${tiers.length}`)

		return tiers;
	});

export const inactiveUserTiers = derived(
	[allUserTiers, userTiers],
	([$allUserTiers, $userTiers]) => {
		const tiers: NDKSubscriptionTier[] = [];

		for (const tier of $allUserTiers) {
			let active = false;
			for (const t of $userTiers) {
				if (t.tagId() === tier.tagId()) {
					active = true;
					break;
				}
			}

			if (!active) tiers.push(tier);
		}

		return tiers;
	});

export const groupsList = writable<NDKList|undefined>(undefined);

export const userActiveSubscriptions = writable<Map<Hexpubkey, string>>(new Map());

/**
 * Current user app handlers
 */
type AppHandlerType = string;
type Nip33EventPointer = string;
export const userAppHandlers = persist(
	writable<Map<number, Map<AppHandlerType, Nip33EventPointer>>>(new Map()),
	createLocalStorage(),
	'user-app-handlers'
);

/**
 * Current user's lists
 */
export const userArticleCurations = writable<Map<string, NDKList>>(new Map());
export const userVideoCurations = writable<Map<string, NDKList>>(new Map());
export const userGenericCuration = writable<NDKList>(new NDKList($ndk, { kind: NDKKind.BookmarkList, created_at: 0 } as NostrEvent));

/**
 * Current user's supported people
 */
export const userSupport = writable<NDKEvent[]>([]);

/**
 * The user's extended network
 */
export const networkFollows = persist(
	writable<Map<Hexpubkey, number>>(new Map()),
	createLocalStorage(),
	'network-follows-map'
);
export const networkFollowsUpdatedAt = persist(
	writable<number>(0),
	createLocalStorage(),
	'network-follows-updated-at'
)

/**
 * Network's supported people
 */
export const networkSupport = writable<NDKEvent[]>([]);

/**
 * Main entry point to prepare the session.
 */
export async function prepareSession(): Promise<void> {
	console.log("DEBUG prepareSession", new Date())
	const $user = getStore(user);

	if (!$ndk || !$user) {
		return;
	}

	d(`running prepareSession`);

	return new Promise((resolve) => {
		const alreadyKnowFollows = getStore(userFollows).size > 0;

		console.log("DEBUG prepareSession fetchData", new Date())
		fetchData('user', $ndk, [$user.pubkey], {
			profileStore: userProfile,
			followsStore: userFollows,
			userArticleCurationsStore: userArticleCurations,
			userVideoCurationsStore: userVideoCurations,
			userGenericCurationStore: userGenericCuration,
			userTierStore: allUserTiers,
			groupsListStore: groupsList,
			tierListStore: tierList,
			activeSubscriptionsStore: userActiveSubscriptions,
			appHandlersStore: userAppHandlers,
			supportStore: userSupport,
			waitUntilEoseToResolve: !alreadyKnowFollows,
			listsKinds: [
				NDKKind.ArticleCurationSet,
				NDKKind.VideoCurationSet,
				NDKKind.CategorizedHighlightList,
				NDKKind.BookmarkList,
			]
		}).then(() => {
			const $userFollows = getStore(userFollows);

			resolve();

			const $networkFollows = get(networkFollows);
			const $networkFollowsUpdatedAt = get(networkFollowsUpdatedAt);
			const twoWeeksAgo = Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 14;

			if ($networkFollows.size < 1000 || $networkFollowsUpdatedAt < twoWeeksAgo) {
				const kind3RelaySet = NDKRelaySet.fromRelayUrls(["wss://purplepag.es"], $ndk);

				fetchData('wot', $ndk, Array.from($userFollows), {
					followsStore: networkFollows,
					closeOnEose: true
				}, kind3RelaySet).then(() => {
					networkFollowsUpdatedAt.set(Math.floor(Date.now() / 1000));
				})

				fetchData('network-support', $ndk, Array.from($userFollows), {
					supportStore: networkSupport,
					closeOnEose: true
				}, getDefaultRelaySet())
			}
		});
	});
}

export const processUserProfile = (event: NDKEvent, store: Writable<UserProfileType | undefined>) => {
	const $store = get(store);

	if (event.created_at && (
		!$store?.created_at ||
		event.created_at > $store.created_at
	)) {
		const profile = profileFromEvent(event) as UserProfileType;
		profile.created_at = event.created_at;
		profile.categories = event.getMatchingTags("c").map((t) => t[1]);
		store.set(profile);
		d(`updating profile`, event.created_at, $store?.created_at, profile.lud16, profile);
		d(`profile is now`, get(store))
	} else {
		d(`skipping profile update`, event.created_at, $store?.created_at);
	}
}

interface IFetchDataOptions {
	profileStore?: Writable<UserProfileType | undefined>;
	followsStore?: Writable<Set<Hexpubkey>> | Writable<Map<Hexpubkey, number>>;
	superFollowsStore?: Writable<Set<Hexpubkey>>;
	activeSubscriptionsStore?: Writable<Map<Hexpubkey, string>>;
	supportStore?: Writable<NDKEvent[]>;
	appHandlersStore?: Writable<Map<number, Map<AppHandlerType, Nip33EventPointer>>>;
	userArticleCurationsStore?: Writable<Map<string, NDKList>>;
	userVideoCurationsStore?: Writable<Map<string, NDKList>>;
	userGenericCurationStore?: Writable<NDKList>;
	userTierStore?: Writable<NDKSubscriptionTier[]>;
	groupsListStore?: Writable<NDKList | undefined>;
	tierListStore?: Writable<NDKList | undefined>;
	listsKinds?: number[];
	extraKinds?: number[];
	closeOnEose?: boolean;
	waitUntilEoseToResolve?: boolean;
}

/**
 * Fetches the information regarding the current user.
 * At this stage, we still don't know the user's network.
 *
 * * Protects from receiving multiple duplicated events
 * * Protects from unnecessarily calling updateFollows if the
 * * eventId is not different than something already processed
 */
async function fetchData(
	name: string,
	$ndk: NDKSvelte,
	authors: string[],
	opts: IFetchDataOptions,
	relaySet?: NDKRelaySet
): Promise<void> {
	// set defaults
	opts.waitUntilEoseToResolve ??= true;
	opts.closeOnEose ??= false;
	opts.listsKinds ??= NDKListKinds;

	const mostRecentEvents: Map<string, NDKEvent> = new Map();
	const processedIdForKind: Record<number, string> = {};
	const _ = d.extend(`fetch:${name}`);

	_({ waitUntilEoseToResolve: opts.waitUntilEoseToResolve });

	const processEvent = (event: NDKEvent) => {
		const dedupKey = event.deduplicationKey();
		const existingEvent = mostRecentEvents.get(dedupKey);

		if (existingEvent && event.created_at! < existingEvent.created_at!) {
			return;
		}

		mostRecentEvents.set(dedupKey, event);

		if (event.kind === 3 && opts.followsStore) {
			processContactList(event, opts.followsStore);
		} else if (event.kind === 0 && opts.profileStore) {
			processUserProfile(event, opts.profileStore);
		} else if (event.kind === NDKKind.GroupMembers && opts.activeSubscriptionsStore) {
			processSubscriptionList(event, authors[0]);
		} else if (event.kind === NDKKind.Subscribe) {
			processSupport(event);
		} else if (event.kind === NDKKind.AppRecommendation) {
			processAppRecommendation(event);
		} else if (event.kind === NDKKind.TierList) {
			processTierList(event);
		} else if (event.kind === NDKKind.SimpleGroupList) {
			groupsListStore(event);
		} else if (event.kind === NDKKind.SubscriptionTier) {
			processSubscriptionTier(event);
		} else if ([
			NDKKind.ArticleCurationSet,
			NDKKind.VideoCurationSet,
			NDKKind.BookmarkList,
		].includes(event.kind!)) {
			processCurationList(event);
		}
	};

	const processSubscriptionList = (event: NDKEvent, author: string) => {
		opts.activeSubscriptionsStore!.update((activeSubscriptions) => {
			const userTag = event.getMatchingTags('p').find((t) => t[1] === author);
			const dTag = event.tagValue('d');

			if (userTag && dTag) {
				const tier = userTag[2];
				activeSubscriptions.set(dTag, tier);
			}

			return activeSubscriptions;
		});
	};

	const processSupport = (event: NDKEvent) => {
		opts.supportStore!.update((support) => {
			support.push(event);

			return support;
		});
	};

	const processTierList = (event: NDKEvent) => {
		opts.tierListStore!.update((tierList) => {
			if (tierList && event.created_at! < tierList.created_at!) return tierList;
			return NDKList.from(event);
		});
	}

	const groupsListStore = (event: NDKEvent) => {
		opts.groupsListStore!.update((groupsList) => {
			if (groupsList && event.created_at! < groupsList.created_at!) return groupsList;
			return NDKList.from(event);
		});
	}

	const processSubscriptionTier = (event: NDKEvent) => {
		opts.userTierStore!.update((tiers) => {
			const tier = NDKSubscriptionTier.from(event);

			d(`Found tier ${tier.title}`, tier.isValid);

			tiers.push(tier);

			return tiers;
		});
	};

	const processAppRecommendation = (event: NDKEvent) => {
		opts.appHandlersStore!.update((appHandlersStore) => {
			if (!event.dTag) return appHandlersStore;
			const handlerKind = parseInt(event.dTag!);
			const val = appHandlersStore.get(handlerKind) || new Map();

			for (const tag of event.getMatchingTags('a')) {
				const [, eventPointer, , handlerType] = tag;
				val.set(handlerType || 'default', eventPointer);
			}

			appHandlersStore.set(handlerKind, val);

			return appHandlersStore;
		});
	};

	/**
	 * Called when a newer event of kind 3 is received.
	 */
	const processContactList = (event: NDKEvent, store: Writable<Set<Hexpubkey> | Map<Hexpubkey, number>>) => {
		if (event.id !== processedIdForKind[event.kind!]) {
			processedIdForKind[event.kind!] = event.id;
			updateFollows(event, store);
		}
	};

	const processCurationList = (event: NDKEvent) => {
		const list = NDKList.from(event);

		if (!list.title) return;

		switch (event.kind) {
			case NDKKind.ArticleCurationSet:
				opts.userArticleCurationsStore!.update((lists) => {
					lists.set(list.tagId(), list);
					return lists;
				});
				break;
			case NDKKind.VideoCurationSet:
				opts.userVideoCurationsStore!.update((lists) => {
					lists.set(list.tagId(), list);
					return lists;
				});
				break;
			case NDKKind.BookmarkList:
				opts.userGenericCurationStore!.update((existingList) => {
					if (existingList!.created_at && existingList.created_at > event.created_at!) return existingList;
					return list;
				});
				break;
		}
	};

	const updateFollows = (event: NDKEvent, store: Writable<Set<Hexpubkey> | Map<Hexpubkey, number>>) => {
		const follows = event.tags
			.filter((t: NDKTag) => t[0] === 'p')
			.map((t: NDKTag) => t[1])
			.filter((f: Hexpubkey) => {
				try {
					nip19.npubEncode(f);
					return true;
				} catch { return false; }
			});

		// if authors has more than one, add the current data, otherwise replace
		if (authors.length > 1) {
			opts.followsStore!.update((existingFollows: Set<Hexpubkey> | Map<Hexpubkey, number>) => {
				follows.forEach((f) => {
					if (existingFollows instanceof Map) {
						const current = existingFollows.get(f) || 0;
						existingFollows.set(f, current + 1);
					} else if (existingFollows instanceof Set) {
						existingFollows.add(f)
					}
				});
				return existingFollows;
			});
		} else store!.set(new Set(follows));
	};

	return new Promise((resolve) => {
		const kinds = opts.extraKinds ?? [];
		let authorPubkeyLength = 64;
		if (authors.length > 10) {
			authorPubkeyLength -= Math.floor(authors.length / 10);

			if (authorPubkeyLength < 5) authorPubkeyLength = 6;
		}

		const authorPrefixes = authors.map((f) => f.slice(0, authorPubkeyLength));

		if (opts.profileStore) { kinds.push(NDKKind.Metadata); }

		if (opts.userArticleCurationsStore) {
			kinds.push(...opts.listsKinds!);
		}

		const filters: NDKFilter[] = [];

		if (kinds.length > 0) {
			filters.push({ kinds, authors: authorPrefixes, limit: 10 });
		}

		if (opts.groupsListStore) kinds.push(NDKKind.SimpleGroupList);
		if (opts.appHandlersStore) kinds.push(NDKKind.AppRecommendation);

		if (opts.userTierStore) {
			kinds.push(NDKKind.SubscriptionTier);
			kinds.push(NDKKind.TierList);
		}

		if (opts.followsStore) {
			filters.push({ kinds: [3], authors: authorPrefixes });
		}

		if (opts.activeSubscriptionsStore) {
			filters.push({
				kinds: [NDKKind.GroupMembers],
				authors: [creatorRelayPubkey],
				'#p': authorPrefixes
			});
		}

		if (opts.supportStore) {
			filters.push({ authors: authorPrefixes, kinds: [7001 as number] });
		}

		const userDataSubscription = $ndk.subscribe(filters, {
			closeOnEose: opts.closeOnEose!,
			groupable: false,
			cacheUsage: NDKSubscriptionCacheUsage.PARALLEL,
			subId: `session:${name}`
		}, relaySet);

		userDataSubscription.on('event', processEvent);

		userDataSubscription.on('eose', () => {
			_(`received eose`);

			// if (kind3Key) {
			//     const mostRecentKind3 = mostRecentEvents.get(kind3Key!);

			//     // Process the most recent kind 3
			//     if (mostRecentKind3!.id !== processedKind3Id) {
			//         processedKind3Id = mostRecentKind3!.id;
			//         updateFollows(mostRecentKind3!);
			//     }
			// }

			if (opts.waitUntilEoseToResolve) {
				_(`resolving`);
				resolve();
			}
		});

		if (!opts.waitUntilEoseToResolve) {
			_(`resolve without waiting for eose`);
			resolve();
		}
	});
}
