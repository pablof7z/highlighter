import { EVENT_ID_SUFFIX_LENGTH } from '$utils/url';
import { NDKSubscription, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import { ndk } from "$stores/ndk";
import type { NDKEvent, NDKFilter } from '@nostr-dev-kit/ndk';
import { get } from 'svelte/store';

export async function load({ params }) {
	const { id } = params;
	let { tagId } = params;

	tagId = decodeURIComponent(tagId);

	console.log('loading', { id, tagId });

	const $ndk = get(ndk);
	$ndk.debug.enabled = true;
	const user = await $ndk.getUserFromNip05(id);

	let event: NDKEvent | undefined;

	if (user) {
		const filters: NDKFilter[] = [{ authors: [user.pubkey], '#d': [tagId] }];
		const regex = new RegExp(`^[0-9a-fA-F]{${EVENT_ID_SUFFIX_LENGTH}}$`);
		if (tagId.match(regex)) {
			filters.push({ ids: [tagId] });
		}

		console.log({ filters });

		const subscription = new NDKSubscription($ndk, filters, {
			cacheUsage: NDKSubscriptionCacheUsage.PARALLEL,
			groupable: false,
			closeOnEose: true
		});
		subscription.on('event', (e: NDKEvent) => {
			event = e;
		});
		await $ndk.cacheAdapter?.query(subscription);
	}

	console.log('will return', { event: event }, typeof event);

	if (event) {
		return {
			event: event.rawEvent()
		};
	} else {
		console.log('no event');
		return {};
	}
}
