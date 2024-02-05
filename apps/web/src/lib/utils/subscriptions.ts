import 'websocket-polyfill';
import NDK, {
	NDKArticle,
	NDKEvent,
	NDKKind,
	NDKRelay,
	NDKRelayStatus,
	PublishError,
	type NostrEvent,
	NDKSubscriptionStart,
	NDKSubscriptionReceipt
} from '@nostr-dev-kit/ndk';
import { getDefaultRelaySet } from './ndk';
import createDebug from 'debug';
import { get } from 'svelte/store';
import { ndk } from '@kind0/ui-common';
import { calculateEndOfTerm } from './term';

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

export function getTierIdFromSubscriptionEvent(event: NDKEvent): string | undefined {
	const tierEventString = event.tagValue('event');

	if (!tierEventString) return undefined;

	try {
		const tierEvent = new NDKArticle(undefined, JSON.parse(tierEventString));
		return tierEvent.tagValue('d');
	} catch (error) {
		return undefined;
	}
}

export async function recordValidSubscriptionPayment(
	subscription: NDKSubscriptionStart
) {
	const $ndk = get(ndk);

	const amount = subscription.amount;
	if (!amount) {
		throw new Error('No amount in subscription');
	}
	const term = amount.term;

	const receipt = new NDKSubscriptionReceipt($ndk);
	receipt.subscriptionStart = subscription;
	receipt.validPeriod = {
		start: new Date(),
		end: calculateEndOfTerm(term, new Date())
	};
	await receipt.sign();
	await receipt.publish();

	d(`subscription receipt`, JSON.stringify(receipt.rawEvent()));
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
	const relaySet = getDefaultRelaySet();
	d('will fetch events', { creatorPubkey });
	const relayUser = await ndk.signer?.user();

	if (!relayUser) {
		throw new Error('Relay user not available');
	}

	const events = await ndk.fetchEvents(
		{
			authors: [relayUser?.pubkey],
			kinds: [NDKKind.GroupMembers],
			'#d': [creatorPubkey]
		},
		undefined
	);
	let event = Array.from(events)[0];
	d('fetched event', event?.rawEvent());

	if (!event) {
		d('creating new list of supporters event');
		event = new NDKEvent(ndk, {
			kind: NDKKind.GroupMembers,
			content: '',
			tags: [['d', creatorPubkey]]
		} as NostrEvent);
	} else {
		d('found existing list of supporters event', event.rawEvent());
	}

	// check that we don't have a p tag with t
	const alreadyPresent = event
		.getMatchingTags('p')
		.find(([, pubkey, tier]) => pubkey === subscriberPubkey && tier === tierDTag);

	if (alreadyPresent) {
		d('supporter was already present', { subscriberPubkey, tierDTag });
		return;
	}

	d('adding supporter', { subscriberPubkey, tierDTag });

	const tag = ['p', subscriberPubkey];
	if (tierDTag) tag.push(tierDTag);
	event.tags.push(tag);
	event.id = '';
	event.sig = '';

	d('adding subcriber tag', tag);
	d('creator has a total of ', event.getMatchingTags('p').length, 'subscribers');

	const publishAttempt = async (event: NDKEvent) => {
		try {
			// go through the relays and see if they are connected, if they are not, attempt to connect
			for (const relay of relaySet.relays) {
				if (relay.status === NDKRelayStatus.DISCONNECTED) {
					d('connecting to relay', relay.url, relay.status);
					await relay.connect();
				}
			}

			d('publishing list of supporters event', event.rawEvent());
			await event.publish(relaySet);
		} catch (error) {
			console.log('Error publishing event', error);

			if (error instanceof PublishError) {
				// error.errors is a map of relay url to error
				for (const [relay, error] of error.errors as Map<NDKRelay, Error>) {
					d(relay.url, error);
				}
			}

			for (const relay of relaySet.relays) {
				d(relay.url, relay.status);
				d(relay.url, relay.connectionStats);
			}
			for (const relay of relaySet.relays) {
				d(relay.url, relay.status);
				d(relay.url, relay.connectionStats);
			}
			setTimeout(() => publishAttempt(event), 5000);
		}
	};

	await publishAttempt(event);
}
