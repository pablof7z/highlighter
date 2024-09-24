import { get as getStore, type Writable, derived, get } from 'svelte/store';
import { ndk } from "$stores/ndk";
import {
	NDKEvent,
	NDKList,
	NDKKind,
	NDKListKinds,
	type Hexpubkey,
	profileFromEvent,
	NDKRelaySet,
	NostrEvent,
	NDKSubscriptionCacheUsage,
	NDKFilter,
} from '@nostr-dev-kit/ndk';
import type NDKSvelte from '@nostr-dev-kit/ndk-svelte';
import { persist, createLocalStorage, createNoopStorage, createIndexedDBStorage } from '@macfja/svelte-persistent-store';
import createDebug from 'debug';
import type { UserProfileType } from '../../app';
import { filterValidPTags } from '$utils/event';
import currentUser from './currentUser';
import { writable } from 'svelte/store';
import { creatorRelayPubkey } from '$utils/const';
import { notificationsSubscribe } from './notifications';
import { onPaymentComplete, walletInit } from './wallet.js';
import { initGroups } from './groups';

const d = createDebug('HL:session');
const $ndk = getStore(ndk);

type PubkeysFollowCount = Map<Hexpubkey, number>;

interface GroupEntry {
	groupId: Hexpubkey;
	relayUrl: WebSocket["url"];
}

export const userProfile = persist(
	writable<UserProfileType | undefined>(undefined),
	createLocalStorage(),
	'user-profile'
);

export const debugMode = writable<boolean>(false);

export const userBlossom = writable<NDKList | null>(null);
export const activeBlossomServer = persist(
	writable<string>("https://blossom.primal.net"),
	createLocalStorage(),
	'active-blossom-server'
);

export const userFollows = writable(new Set<Hexpubkey>());

// export const userFollows = persist(
// 	writable(new Set<Hexpubkey>()),
// 	createLocalStorage(),
// 	'user-follows-set'
// );



export const muteList = persist(
	writable(new Set<Hexpubkey>()),
	createLocalStorage(),
	'user-mute-list'
);

// This is an in-memory store that is persisted once the compute finishes
const _networkFollows = writable(new Map<Hexpubkey, number>());

export const networkFollows = persist(
	writable(new Map<Hexpubkey, number>()),
	createIndexedDBStorage(),
	'network-follows-map'
);

export const networkGroupsList = persist(
	writable(new Map<GroupEntry, number>()),
	createLocalStorage(),
	'network-groups-lists'
);

export const tierList = writable<NDKList|undefined>(undefined);

export const groupsList = writable<NDKList|undefined>(undefined);

export const userActiveSubscriptions = writable<Map<Hexpubkey, string>>(new Map());

/**
 * Current user's lists
 */
export const userArticleCurations = writable<Map<string, NDKList>>(new Map());
export const userHighlightCurations = writable<Map<string, NDKList>>(new Map());
export const userVideoCurations = writable<Map<string, NDKList>>(new Map());
export const userGenericCuration = writable<NDKList>(new NDKList($ndk, { kind: NDKKind.BookmarkList, created_at: 0 } as NostrEvent));

export const categorizedUserLists = writable<Map<string, NDKList>>(new Map());

/**
 * Current user's supported people
 */
export const userSupport = writable<NDKEvent[]>([]);

/**
 * The user's extended network
 */
export const sessionUpdatedAt = persist(
	writable<number>(0),
	createLocalStorage(),
	'session-updated-at'
)

/**
 * Main entry point to prepare the session.
 */
export async function prepareSession(): Promise<void> {
	d("DEBUG prepareSession", new Date())
	const $currentUser = getStore(currentUser);

	if (!$ndk || !$currentUser) {
		return;
	}

	return new Promise<void>(async (resolve) => {
		const alreadyKnowFollows = getStore(userFollows).size > 0;
		const $sessionUpdatedAt = alreadyKnowFollows ? get(sessionUpdatedAt) : undefined;

		$ndk.walletConfig ??= {onPaymentComplete};
		$ndk.walletConfig.onPaymentComplete = onPaymentComplete;

		fetchData('user', $ndk, [$currentUser.pubkey], {
			profileStore: userProfile,
			followsStore: userFollows,
			mutesStore: muteList,
			blossomStore: userBlossom,
			userArticleCurationsStore: userArticleCurations,
			userHighlightCurationsStore: userHighlightCurations,
			userVideoCurationsStore: userVideoCurations,
			userGenericCurationStore: userGenericCuration,
			categorizedUserListsStore: categorizedUserLists,
			groupsListStore: groupsList,
			tierListStore: tierList,
			activeSubscriptionsStore: userActiveSubscriptions,
			waitUntilEoseToResolve: !alreadyKnowFollows,
			listsKinds: [
				NDKKind.ArticleCurationSet,
				NDKKind.VideoCurationSet,
				NDKKind.HighlightSet,
				NDKKind.BookmarkList,
				NDKKind.CategorizedPeopleList,
				NDKKind.TierList
			],

			since: $sessionUpdatedAt,
		}).then(() => {
			const $currentUserFollows = getStore(userFollows);

			resolve();

			notificationsSubscribe($ndk, $currentUser);
			// walletInit($ndk);

			const $groupsList = get(groupsList);
			if ($groupsList) {
				initGroups($groupsList);
			} else {
				console.log('here')
			}

			const $userFollows = get(userFollows);
			const $networkFollows = get(networkFollows);
			const oneHourAgo = Math.floor(Date.now() / 1000) + 60 * 60;

			d(`tracking user follows %d`, $userFollows.size);
			$ndk.outboxTracker!.trackUsers(Array.from($userFollows));

			if ($networkFollows.size < 1000 || !$sessionUpdatedAt || $sessionUpdatedAt < oneHourAgo) {
				const kind3RelaySet = NDKRelaySet.fromRelayUrls(["wss://purplepag.es/"], $ndk);

				fetchData('wot', $ndk, Array.from($currentUserFollows), {
					followsStore: _networkFollows,
					groupsCountStore: networkGroupsList,
					closeOnEose: true,
					since: $sessionUpdatedAt,
				}, kind3RelaySet).then(() => {
					const start = Date.now();
					networkFollows.set(get(_networkFollows));
					const end = Date.now();
					const diff = end - start;
					console.log(`networkFollows.set took ${diff}ms`);
					sessionUpdatedAt.set(Math.floor(Date.now() / 1000));
				})
			}
		});
	}).catch((e) => {
		console.error(e);
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
	followsStore?: Writable<Set<Hexpubkey> | PubkeysFollowCount>;
	mutesStore?: Writable<Set<Hexpubkey>>;
	blossomStore?: Writable<NDKEvent | null>;
	activeSubscriptionsStore?: Writable<Map<Hexpubkey, string>>;
	userArticleCurationsStore?: Writable<Map<string, NDKList>>;
	userHighlightCurationsStore?: Writable<Map<string, NDKList>>;
	userVideoCurationsStore?: Writable<Map<string, NDKList>>;
	userGenericCurationStore?: Writable<NDKList>;
	categorizedUserListsStore?: Writable<Map<string, NDKList>>;
	groupsListStore?: Writable<NDKList | undefined>;
	groupsCountStore?: Writable<Map<GroupEntry, number>>;
	tierListStore?: Writable<NDKList | undefined>;
	listsKinds?: number[];
	extraKinds?: number[];
	closeOnEose?: boolean;
	waitUntilEoseToResolve?: boolean;

	/**
	 * Used to fetch events since a specific timestamp.
	 */
	since?: number;
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
		} else if (event.kind === 10063) {
			processBlossomList(event);
		} else if (event.kind === 0 && opts.profileStore) {
			processUserProfile(event, opts.profileStore);
		} else if (event.kind === NDKKind.GroupMembers && opts.activeSubscriptionsStore) {
			processSubscriptionList(event, authors[0]);
		} else if (event.kind === NDKKind.AppRecommendation) {
		} else if (event.kind === NDKKind.TierList) {
			processTierList(event);
		} else if (event.kind === NDKKind.SimpleGroupList && opts.groupsListStore) {
			groupsListStore(event);
		} else if (event.kind === NDKKind.SimpleGroupList && opts.groupsCountStore) {
			groupsCountsStore(event);
		} else if ([
			NDKKind.ArticleCurationSet,
			NDKKind.VideoCurationSet,
			NDKKind.BookmarkList,
			NDKKind.CategorizedPeopleList
		].includes(event.kind!)) {
			processCurationList(event);
		}
	};

	const processBlossomList = (event: NDKEvent) => {
		opts.blossomStore!.update((blossomList) => {
			if (blossomList && event.created_at! < blossomList.created_at!) return blossomList;
			const list = NDKList.from(event);
			let firstItem = list.items[0]?.[1];
			firstItem ??= "https://blossom.primal.net"

			activeBlossomServer.set(firstItem);
			return list;
		});
	}

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

	const processTierList = (event: NDKEvent) => {
		opts.tierListStore!.update((tierList) => {
			if (tierList && event.created_at! < tierList.created_at!) return tierList;
			return NDKList.from(event);
		});
	}

	const groupsListStore = (event: NDKEvent) => {
		opts.groupsListStore!.update((groupsList) => {
			if (groupsList && event.created_at! < groupsList.created_at!) return groupsList;
			const list = NDKList.from(event);

			for (const item of list.items) {
				if (item[0] === "group") {
					const relays = item.slice(2);

					for (const relay of relays) {
						$ndk.pool.getRelay(relay, true, false);
					}
				}
			}

			// ensure we connect to the relays as soon as we see them
			return list;
		});
	}

	const groupsCountsStore = (event: NDKEvent) => {
		opts.groupsCountStore!.update((groupsCounts) => {
			const list = NDKList.from(event);
			const groups = list.getMatchingTags("group");

			for (const group of groups) {
				const groupId = group[1];
				const relay = group[2]??'';
				const count = groupsCounts.get({ groupId, relayUrl: relay }) ?? 0;
				groupsCounts.set({ groupId, relayUrl: relay }, count + 1);
			}

			return groupsCounts;
		});
	}

	const processContactList = (event: NDKEvent, store: Writable<Set<Hexpubkey> | PubkeysFollowCount>) => {
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
			case NDKKind.HighlightSet:
					opts.userHighlightCurationsStore!.update((lists) => {
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
			case NDKKind.CategorizedPeopleList:
				opts.categorizedUserListsStore!.update((lists) => {
					const dTag = list.dTag;
					if (dTag === undefined) return lists;

					const existing = lists.get(dTag);
					if (existing && existing.created_at! > list.created_at!) return lists;
					lists.set(list.dTag!, list);
					return lists;
				});
				break;
		}
	};

	function withSinceFilter(filter: NDKFilter) {
		if (opts.since) filter.since = opts.since;
		return filter;
	}

	const updateFollows = (
		event: NDKEvent,
		store: Writable<Set<Hexpubkey> | PubkeysFollowCount>,
	) => {
		const follows = filterValidPTags(event.tags);

		store.update((existingFollows: Set<Hexpubkey> | PubkeysFollowCount) => {
			if (existingFollows instanceof Set) {
				return new Set(follows);
			} else if (existingFollows instanceof Map) {
				follows.forEach((f) => {
					const current = existingFollows.get(f) || 0;
					existingFollows.set(f, current + 1);
				});
				return existingFollows;
			}

			throw new Error('Invalid store type');
		});
	};

	return new Promise((resolve) => {
		const kinds = opts.extraKinds ?? [];
		let authorPubkeyLength = 64;
		if (authors.length > 10) {
			authorPubkeyLength -= Math.floor(authors.length / 10);

			if (authorPubkeyLength < 5) authorPubkeyLength = 6;
		}

		if (opts.profileStore) { kinds.push(NDKKind.Metadata); }

		if (opts.userArticleCurationsStore) {
			kinds.push(...opts.listsKinds!);
		}

		const filters: NDKFilter[] = [];

		if (kinds.length > 0) {
			filters.push({ kinds, authors, limit: 50 });
		}

		if (opts.blossomStore) kinds.push(10063 as number);
		if (opts.groupsListStore) kinds.push(NDKKind.SimpleGroupList);

		if (opts.followsStore) {
			filters.push(withSinceFilter({ kinds: [3], authors, limit: 50 }));
		}

		if (opts.activeSubscriptionsStore) {
			filters.push({
				kinds: [NDKKind.GroupMembers],
				authors: [creatorRelayPubkey],
				'#p': authors
			});
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
