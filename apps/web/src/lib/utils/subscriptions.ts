import 'websocket-polyfill';
import NDK, {
	NDKArticle,
	NDKEvent,
	NDKSubscriptionStart,
} from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { get } from 'svelte/store';
import { ndk } from '@kind0/ui-common';
import nip29 from '$lib/nip29';
import { publishSubscriptionReceipt } from './nip88';
import { getDefaultRelaySet } from './ndk';
import { getTierIdFromSubscriptionEvent } from '../events/tiers';

const d = createDebug('HL:subscriptions');

export function getTierNameFromSubscriptionEvent(event: NDKEvent): string | undefined {
	const tierEventString = event.tagValue('event');

	if (!tierEventString) return undefined;

	try {
		const tierEvent = new NDKArticle(undefined, JSON.parse(tierEventString));
		return tierEvent.title;
	} catch (error) {
		return undefined;
	}
}

export async function recordValidSubscriptionPayment(
	subscription: NDKSubscriptionStart
) {
	const $ndk = get(ndk);

	return publishSubscriptionReceipt($ndk, subscription);
}

/**
 * Creates a list of pubkeys that are currently supporting a creator.
 * The "d" tag is the pubkey of the creator.
 * THe "p" tag is the pubkey of the supporter with a marker of the tier they are supporting.
 */
export async function addToListOfSupporters(
	ndk: NDK,
	creatorPubkey: string,
	subscriptionEvent: NDKEvent
) {
	d('addToListOfSupporters', {
		creatorPubkey,
		subscriptionEvent: subscriptionEvent.rawEvent()
	});

	const subscriberPubkey = subscriptionEvent.pubkey;
	const tierDTag = getTierIdFromSubscriptionEvent(subscriptionEvent);
	d('tierDTag', tierDTag);

	await nip29.addGroupMember(ndk, creatorPubkey, subscriberPubkey, getDefaultRelaySet());
}
