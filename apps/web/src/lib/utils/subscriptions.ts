import 'websocket-polyfill';
import NDK, {
	NDKArticle,
	NDKEvent,
	NDKKind,
	NDKRelay,
	NDKRelayStatus,
	PublishError,
	type NostrEvent
} from '@nostr-dev-kit/ndk';
import { getDefaultRelaySet } from './ndk';
import createDebug from 'debug';

const debug = createDebug('highlighter:subscriptions');

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
	debug('addToListOfSupporters', {
		creatorPubkey,
		subscriptionEvent: subscriptionEvent.rawEvent()
	});
	const subscriberPubkey = subscriptionEvent.pubkey;
	const tierDTag = getTierIdFromSubscriptionEvent(subscriptionEvent);
	debug('tierDTag', tierDTag);
	const relaySet = getDefaultRelaySet();
	debug('will fetch events', { creatorPubkey });
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
	debug('fetched event', event?.rawEvent());

	if (!event) {
		debug('creating new list of supporters event');
		event = new NDKEvent(ndk, {
			kind: NDKKind.GroupMembers,
			content: '',
			tags: [['d', creatorPubkey]]
		} as NostrEvent);
	} else {
		debug('found existing list of supporters event', event.rawEvent());
	}

	// check that we don't have a p tag with t
	const alreadyPresent = event
		.getMatchingTags('p')
		.find(([, pubkey, tier]) => pubkey === subscriberPubkey && tier === tierDTag);

	if (alreadyPresent) {
		debug('supporter was already present', { subscriberPubkey, tierDTag });
		return;
	}

	debug('adding supporter', { subscriberPubkey, tierDTag });

	const tag = ['p', subscriberPubkey];
	if (tierDTag) tag.push(tierDTag);
	event.tags.push(tag);
	event.id = '';
	event.sig = '';

	debug('adding subcriber tag', tag);
	debug('creator has a total of ', event.getMatchingTags('p').length, 'subscribers');

	const publishAttempt = async (event: NDKEvent) => {
		try {
			// go through the relays and see if they are connected, if they are not, attempt to connect
			for (const relay of relaySet.relays) {
				if (relay.status === NDKRelayStatus.DISCONNECTED) {
					debug('connecting to relay', relay.url, relay.status);
					await relay.connect();
				}
			}

			debug('publishing list of supporters event', event.rawEvent());
			await event.publish(relaySet);
		} catch (error) {
			console.log('Error publishing event', error);

			if (error instanceof PublishError) {
				// error.errors is a map of relay url to error
				for (const [relay, error] of error.errors as Map<NDKRelay, Error>) {
					debug(relay.url, error);
				}
			}

			for (const relay of relaySet.relays) {
				debug(relay.url, relay.status);
				debug(relay.url, relay.connectionStats);
			}
			for (const relay of relaySet.relays) {
				debug(relay.url, relay.status);
				debug(relay.url, relay.connectionStats);
			}
			setTimeout(() => publishAttempt(event), 5000);
		}
	};

	await publishAttempt(event);
}
