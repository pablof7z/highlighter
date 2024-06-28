import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { derived, get, writable, type Readable } from 'svelte/store';
import type { NDKEvent, NDKFilter, NDKUser } from '@nostr-dev-kit/ndk';
import NDKSvelte, { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
import NDK, { NDKKind } from '@nostr-dev-kit/ndk';
import currentUser, { isGuest } from './currentUser';
import { variableStore } from 'svelte-capacitor-store';
import { toast } from 'svelte-sonner';

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

const notificationKinds = [
	1, // Tweet
	9, 10, 12, 9735, 30023, 9802,
	6250, 7000
]

export function notificationsSubscribe(ndk: NDKSvelte, currentUser: NDKUser) {
	const since = get(lastSeenTimestamp);

	const filters: NDKFilter[] = [
		{ kinds: notificationKinds, "#p": [currentUser.pubkey] }
	]

	if (since) {
		filters[0].since = since;
		filters.push({ kinds: notificationKinds, "#p": [currentUser.pubkey], until: since, limit: 100 });
	} else {
		filters[0].limit = 100;
	}
	
	notifications = ndk.storeSubscribe(filters, {
		subId: 'notifications',
		onEvent: processEvent,
		onEose: () => { eosed = true }
	});

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

let eosed = false;

function processEvent(event: NDKEvent) {
	const recent = event.created_at! * 1000 > Date.now() - 5000 && event.created_at! * 1000 < Date.now() + 5000;

	console.log({ kind: event.kind, recent, eosed });

	if (event.kind === 7000 && eosed && recent) {
		toast.success(event.content);
	}
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

export const mobileNotifications = variableStore<boolean | null>({
    storeName: 'mobile-notifications',
    initialValue: null,
    persist: true,
    browserStorage: 'localStorage',
});