import { ndk, user as currentUser } from '@kind0/ui-common';
import { NDKKind, NDKEvent, NDKSubscriptionCacheUsage, NDKSubscriptionTier, NDKSubscriptionReceipt } from '@nostr-dev-kit/ndk';
import { type NDKUser, type NDKFilter, type Hexpubkey, NDKHighlight } from '@nostr-dev-kit/ndk';
import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
import { writable, get as getStore, derived, type Readable } from 'svelte/store';
import { userActiveSubscriptions } from './session';
import createDebug from 'debug';
import { mainContentKinds } from '$utils/event';
import { creatorRelayPubkey } from '$utils/const';

const d = createDebug('HL:user-view');

export const activeUserViewPubkey = writable<Hexpubkey | undefined>(undefined);

export let userSubscription: NDKEventStore<NDKEvent> | undefined = undefined;
export const userSupporters = writable<
	Readable<never[] | Record<Hexpubkey, string | boolean>> | undefined
>(undefined);

export function startUserView(user: NDKUser) {
	const $activeUserViewPubkey = getStore(activeUserViewPubkey);
	d('start', user.pubkey);

	// if we are already subscribed to this user, do nothing
	if (userSubscription && $activeUserViewPubkey === user.pubkey) return;

	const $ndk = getStore(ndk);
	const $userActiveSubscriptions = getStore(userActiveSubscriptions);
	const tier = $userActiveSubscriptions.get(user.pubkey) || 'Free';
	const $currentUser = getStore(currentUser);

	d(`using tier ${tier}`);

	if (userSubscription && $activeUserViewPubkey !== user.pubkey) {
		d(`unsubscribing from user ${$activeUserViewPubkey} to subscribe to ${user.pubkey}`);
		userSubscription.unsubscribe();
	}

	activeUserViewPubkey.set(user.pubkey);

	const filters: NDKFilter[] = [
		// supporting options
		{
			kinds: [NDKKind.SubscriptionTier as number, NDKKind.TierList],
			authors: [user.pubkey]
		},
		{
			kinds: [NDKKind.SubscriptionReceipt as number],
			authors: [creatorRelayPubkey],
			'#p': [user.pubkey]
		},
		{
			kinds: [NDKKind.GroupMembers as number],
			'#d': [user.pubkey],
			authors: [creatorRelayPubkey]
		},
		// Non group-exclusive content
		{
			kinds: [...mainContentKinds, NDKKind.Highlight],
			authors: [user.pubkey],
			limit: 200
		}
	];

	const groupFilter: NDKFilter = {
		'#h': [user.pubkey],
		authors: [user.pubkey]
	};

	if (!$currentUser || $currentUser.pubkey !== user.pubkey) {
		groupFilter['#f'] = [tier];
	}

	filters.push(groupFilter);

	console.log('user view filters', filters);

	userSubscription = $ndk.storeSubscribe(filters, {
		subId: 'user-view',
		autoStart: true,
		groupable: false,
	});

	userSupporters.set(getUserSupporters());
}

export function getContent() {
	const $activeUserViewPubkey = getStore(activeUserViewPubkey);

	if (!userSubscription) return derived([], () => []);

	return derived(userSubscription, ($userSubscription) => {
		if (!$userSubscription || !$activeUserViewPubkey) return [];

		const groupContent = $userSubscription.filter((event: NDKEvent) => {
			return event.tagValue('h') === $activeUserViewPubkey;
		});

		return groupContent;
	});
}

export function getUserSubscriptionTiersStore() {
	const $activeUserViewPubkey = getStore(activeUserViewPubkey);

	if (!userSubscription) return derived<[], NDKSubscriptionTier[]>([], () => []);

	return derived(userSubscription, ($userSubscription) => {
		if (!$userSubscription || !$activeUserViewPubkey) return [];

		const tierList = $userSubscription.find((event: NDKEvent) => {
			return event.kind === NDKKind.TierList;
		});

		if (!tierList) return [];

		const tiers: NDKSubscriptionTier[] = [];

		for (const tag of tierList.getMatchingTags('e')) {
			const tier = $userSubscription.find((event: NDKEvent) => {
				if (event.kind !== NDKKind.SubscriptionTier) return false;
				return event.id === tag[1];
			});

			if (!tier) {
				d(`could not find tier ${tag[1]}`);
				continue;
			}

			const t = NDKSubscriptionTier.from(tier);
			if (t.isValid) {
				tiers.push(t);
			} else {
				d(`tier ${t.title} is not valid`, t.rawEvent());
			}
		}

		return tiers;
	});
}

export function getUserCommunityMembers(): Readable<Record<Hexpubkey, string | undefined>> {
	const $activeUserViewPubkey = getStore(activeUserViewPubkey);

	if (!userSubscription) return derived([], () => {});

	return derived(userSubscription, ($userSubscription) => {
		if (!$userSubscription || !$activeUserViewPubkey) return {};

		const supportersList: NDKEvent | undefined = $userSubscription.find(
			(e) => e.kind === NDKKind.GroupMembers
		);

		if (supportersList) {
			const supporters: Record<Hexpubkey, string | undefined> = {};

			for (const pTag of supportersList.getMatchingTags('p')) {
				const pubkey = pTag[1];
				const tier = pTag[2];
				supporters[pubkey] = tier;
			}

			return supporters;
		}

		return {};
	});
}

export function getUserSupporters(): Readable<Record<Hexpubkey, string | true>> {
	const $activeUserViewPubkey = getStore(activeUserViewPubkey);

	if (!userSubscription) return derived([], () => {});

	return derived(userSubscription, ($userSubscription) => {
		if (!$userSubscription || !$activeUserViewPubkey) return {};

		const supporters: Record<Hexpubkey, string | true> = {};

		$userSubscription
			.filter((event: NDKEvent) => event.kind === NDKKind.SubscriptionReceipt)
			.map((event: NDKEvent) => NDKSubscriptionReceipt.from(event))
			.filter((receipt: NDKSubscriptionReceipt) => receipt.isActive() && receipt.isValid)
			.forEach((receipt: NDKSubscriptionReceipt) => {
				const subscriber = receipt.subscriber;
				if (!subscriber) {
					d(`receipt has no subscriber`, receipt.rawEvent());
					return;
				}
				supporters[subscriber.pubkey] = receipt.tierName || true;
			});

		return supporters;
	});
}

export function getReceipts(): Readable<NDKSubscriptionReceipt[]> {
	if (!userSubscription) {
		console.log('no userSubscription');
		return derived([], () => []);
	}

	return derived([userSubscription], ([$userSubscription]) => {
		const items = $userSubscription;

		return items
			.filter((event: NDKEvent) => event.kind === NDKKind.SubscriptionReceipt)
			.map((event: NDKEvent) => NDKSubscriptionReceipt.from(event));
	});
}

export function getSortedSupporters(): Readable<Hexpubkey[]> {
	const receipts = getReceipts();

	return derived(receipts, ($receipts) => {
		const pubkey: Record<Hexpubkey, number> = {};

		// go through the receipts, get the recipient's pubkey and put the lowest created_at in the pubkey object
		for (const receipt of $receipts) {
			const subscriber = receipt.subscriber?.pubkey;
			if (!subscriber) continue;
			if (!pubkey[subscriber] || pubkey[subscriber] > receipt.created_at!) {
				pubkey[subscriber] = receipt.created_at!;
			}
		}

		const sorted: Hexpubkey[] = Object.keys(pubkey).sort((a, b) => {
			if (pubkey[a] < pubkey[b]) return -1;
			if (pubkey[a] > pubkey[b]) return 1;
			return 0;
		});
		return sorted;
	});
}

export function getUserCurations(): Readable<NDKEvent[]> {
	if (!userSubscription) return derived([], () => []);

	return derived([userSubscription], ([$userSubscription]) => {
		const items = $userSubscription;

		// go through all the items, if there is an item that has a "full" tag with a value that exists in ids, remove it
		const filteredItems = items.filter((event: NDKEvent) => {
			if (![NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet].includes(event.kind!)) return false;

			// Only non-h-tagged content
			return !event.tagValue('h');
		});

		return filteredItems;
	});
}

export function getGAUserContent(): Readable<NDKEvent[]> {
	if (!userSubscription) return derived([], () => []);

	return derived([userSubscription], ([$userSubscription]) => {
		const items = $userSubscription;

		// go through all the items, if there is an item that has a "full" tag with a value that exists in ids, remove it
		const filteredItems = items.filter((event: NDKEvent) => {
			if (!mainContentKinds.includes(event.kind!)) return false;

			// Only non-h-tagged content
			return !event.tagValue('h');
		});

		return filteredItems;
	});
}

export function getUserContent(): Readable<NDKEvent[]> {
	if (!userSubscription) return derived([], () => []);

	return derived([userSubscription], ([$userSubscription]) => {
		const items = $userSubscription;
		const ids: string[] = items.map((event: NDKEvent) => event.tagId());

		// go through all the items, if there is an item that has a "full" tag with a value that exists in ids, remove it
		const filteredItems = items.filter((event: NDKEvent) => {
			if (!mainContentKinds.includes(event.kind!)) return false;

			// Only h-tagged content
			const hTag = event.tagValue('h');
			if (!hTag) return false;

			const fullTag = event.tagValue('full');
			if (!fullTag) return true;

			return !ids.includes(fullTag);
		});

		return filteredItems;
	});
}

export function getUserHighlights(): Readable<NDKHighlight[]> {
	if (!userSubscription) {
		d('no userSubscription');
		return derived([], () => []);
	}

	d('getting highlights');

	return derived([userSubscription], ([$userSubscription]) => {
		return $userSubscription
			.filter((event: NDKEvent) => event.kind === NDKKind.Highlight)
			.map((event: NDKEvent) => NDKHighlight.from(event));
	});
}
