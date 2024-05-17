import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { derived, get, writable, type Readable } from 'svelte/store';
import type { NDKEvent, NDKFilter, NDKUser } from '@nostr-dev-kit/ndk';
import NDKSvelte, { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
import NDK, { NDKKind } from '@nostr-dev-kit/ndk';
import currentUser, { isGuest } from './currentUser';

export const seenIds = persist(writable<Set<string>>(new Set()), createLocalStorage(), 'seen-ids');

/**
 * Last seen group timestamp
 * Record<group-id, unix-timestamp>
 */
export const lastSeenGroupTimestamp = persist(
	writable<Record<string, number>>({}),
	createLocalStorage(),
	'last-seen-group-timestamp'
);

export const lastSeenTimestamp = persist(
	writable<number>(),
	createLocalStorage(),
	'last-seen-notif-timestamp'
);

export let unseenEvents: Readable<NDKEvent[]> | undefined;
export const notificationsEnabled = writable(false);

// export function initNotifications() {
// 	if (!userTaggedEvents) {
// 		throw new Error('User tagged events not initialized');
// 	}

// 	console.log(`Initializing notifications`);

// 	// unseenEvents = derived(userTaggedEvents, $userTaggedEvents => {
// 	//     const $seenIds = getStore(seenIds);
// 	//     const $lastSeenTimestamp = getStore(lastSeenTimestamp)
// 	//     const timestampThreshold = Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 1

// 	//     // if (!$lastSeenTimestamp) {
// 	//     //     return $userTaggedEvents;
// 	//     // }

// 	//     return $userTaggedEvents.filter(event => {
// 	//         return event.created_at! > timestampThreshold && !$seenIds?.has(event.id);
// 	//     });
// 	// });

// 	setTimeout(() => {
// 		notificationsEnabled.set(true);
// 	}, 1000);
// }

export function markEventAsSeen(eventId: string) {
	seenIds.update(($seenIds) => {
		$seenIds.add(eventId);
		return $seenIds;
	});
}

export let notifications: NDKEventStore<NDKEvent>;
export let hasUnreadNotifications: Readable<boolean> = writable(false);
export let unreadNotifications: Readable<number>;

export function notificationsSubscribe(ndk: NDKSvelte, currentUser: NDKUser) {
	const since = get(lastSeenTimestamp);

	const filters: NDKFilter[] = [{
		kinds: [NDKKind.Highlight, NDKKind.Text, NDKKind.Article, NDKKind.HorizontalVideo],
		"#p": [currentUser.pubkey],
		limit: 1,
	}]

	if (since) filters[0].since = since;
	
	notifications = ndk.storeSubscribe(filters, {subId: 'notifications'});

	const filteredNotifications = derived(notifications, $notifications => {
		return $notifications.filter(event => event.pubkey !== currentUser.pubkey);
	});

	unreadNotifications = derived([filteredNotifications, lastSeenTimestamp], ([$filteredNotifications, $lastSeenTimestamp]) => {
		if (!$lastSeenTimestamp) {
			return $filteredNotifications.length;
		}
		return $filteredNotifications.filter(event => event.created_at! > $lastSeenTimestamp).length;
	});

	hasUnreadNotifications = derived(unreadNotifications, $unreadNotifications => {
		return $unreadNotifications > 0;
	});
}

/**
 * Whether the notification menu item should be shown
 * (user is logged in as non guest or a guest has notifications)
 */
export let showNotificationOption = derived([
	currentUser, isGuest, hasUnreadNotifications
], ([$currentUser, $isGuest, $hasUnreadNotifications]) => {
	return ($currentUser && (!$isGuest || $hasUnreadNotifications));
});