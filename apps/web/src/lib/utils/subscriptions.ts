import 'websocket-polyfill';
import NDK, {
	NDKArticle,
	NDKEvent,
	NDKKind,
	NDKRelayList,
	NDKRelaySet,
	NDKSubscriptionStart,
	NDKSubscriptionTier,
	NDKUser,
	NostrEvent,
	zapInvoiceFromEvent,
} from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { get } from 'svelte/store';
import { ndk } from '@kind0/ui-common';
import nip29 from '$lib/nip29';
import { publishSubscriptionReceipt } from './nip88';
import { getDefaultRelaySet } from './ndk';
import { getTierIdFromSubscriptionEvent } from '../events/tiers';
import { prettifyNip05 } from '@nostr-dev-kit/ndk-svelte-components';
import { getZapperPubkey } from './zaps';
import { calculateSatAmountFromAmountTag } from './currency';
import { defaultRelays } from './const';

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

async function createAnnouncementContent(event: NDKSubscriptionStart, recipient: NDKUser) {
	let authorUrl: string | undefined;
	const profile = await recipient.fetchProfile();

	if (profile?.nip05 && await recipient.validateNip05(profile.nip05)) {
		authorUrl = prettifyNip05(profile.nip05, 99999);
	}

	if (!authorUrl) authorUrl = recipient.npub;

	// let imageUrl: string | undefined | null;
	// try {
	// 	const prompts = [ "celebrate", "improve", "cascade", "rocket", "create" ]
	// 	const randomPrompt = prompts[Math.floor(Math.random() * prompts.length)];
	// 	const image = 'https://source.unsplash.com/random?'+ randomPrompt;
	// 	const imageResponse = await fetch(image, { redirect: 'manual' });
	// 	imageUrl = imageResponse.headers.get('location');
	// } catch {}

	let s = `🧡 Hooray! nostr:${event.author.npub} is now supporting nostr:${recipient.npub}'s work on nostr:npub1w0rthyjyp2f5gful0gm2500pwyxfrx93a85289xdz0sd6hyef33sh2cu4x\n\nhttps://highlighter.com/${authorUrl}`;

	// if (imageUrl) s += `\n\n${imageUrl}.jpg`;

	return s;
}

export async function announceNewSubscription(
	ndk: NDK,
	subscriptionEvent: NDKSubscriptionStart,
	recipient: NDKUser
) {
	recipient.ndk = ndk;
	const announce = new NDKEvent(ndk, {
		kind: 1,
		content: await createAnnouncementContent(subscriptionEvent, recipient)
	} as NostrEvent);

	await announce.sign();
	console.log('announcement', announce.rawEvent())

	announce.publish();
}

export async function processNewSubscription(
	event: NDKSubscriptionStart,
	recipient: NDKUser,
	ndk: NDK,
	debug: debug.Debugger
) {
	await Promise.all([
		new Promise((resolve) => {
			event.publish().then((relays) => {
				debug(`event published to ${relays.size} relays`);
				resolve(null);
			});
		}),
		new Promise((resolve) => {
			addToListOfSupporters(ndk, recipient.pubkey, event)
				.then(resolve)
				.catch((e) => {
					debug('error adding to list of supporters', e);
					resolve(null);
				});
		}),
		new Promise((resolve) => {
			recordValidSubscriptionPayment(event)
				.then(resolve)
				.catch(e => {
					debug('error recording valid subscription payment', e);
					resolve(null);
				})
		}),
		new Promise((resolve) => {
			announceNewSubscription(ndk, event, recipient)
				.then(resolve)
				.catch(e => {
					debug('error announcing new subscription', e);
					resolve(null);
				})
		})
	]);
}

export async function validateSubscriptionStart(
	event: NDKSubscriptionStart,
) {
	// check if we have a tier event
	console.log('fetching tier');
	const tier = await event.fetchTier();

	console.log('tier from subscription start event', tier?.rawEvent());
}

export async function checkForZapReceipt(
	event: NDKSubscriptionStart,
	relayPubkey: string,
	ndk: NDK
) {
	// validate subscription start
	await validateSubscriptionStart(event);

	// console.log('checking for existing receipt', event.encode());
	
	// check if we already have a kind 7003 for this event
	// const existingReceipt = await ndk.fetchEvents(
    //     { kinds: [7003], ...event.filter(), authors: [relayPubkey] },
	// 	undefined, NDKRelaySet.fromRelayUrls(defaultRelays, ndk)
    // )

    // if (existingReceipt.size > 0) {
	// 	console.log('Already processed');
	// 	throw new Error("Already processed")
	// }

	if (!event.recipient) {
		console.log('No recipient found');
		throw new Error('No recipient found');
	}

	// get recipient's relays
	// const relayList = NDKRelayList.forUser(recipientZapper, ndk);
	// event.recipient

	console.log('checking for zapped amount');

	// check for zap
	const totalZappedAmount = await totalZappedAmountForEvent(event, event.recipient, ndk);
	const expectedAmount = await getExpectedZappedAmount(event);
	const marginOfError = 0.05;

	// hi semisol 👋

	console.log({
		totalZappedAmount,
		expectedAmount,
	})

	if (totalZappedAmount < expectedAmount - marginOfError) {
		console.log('Not enough zapped');

		return false;
	}

	console.log('processing new subscription', event.encode());

	await processNewSubscription(event, event.recipient, ndk, d);

	return true;
}

export async function getExpectedZappedAmount(
	event: NDKSubscriptionStart,
) {
	const amountTag = event.getMatchingTags('amount')[0];

	if (!amountTag) throw new Error('Amount not found');

	return await calculateSatAmountFromAmountTag(amountTag);
}

export async function totalZappedAmountForEvent(
	event: NDKEvent,
	recipient: NDKUser,
	ndk: NDK
) {
	let totalAmount = 0;

	// get recipient zapper
	// const recipientZapper = await getZapperPubkey(recipient);

	// console.log('recipient zapper', recipientZapper);

	// if (!recipientZapper) throw new Error('No recipient zapper found: ' + event.encode());

	const zaps = await ndk.fetchEvents({
		kinds: [NDKKind.Zap], ...event.filter()//, authors: [recipientZapper]
	})

	console.log('zaps', zaps.size);

	for (const zap of zaps) {
		const details = zapInvoiceFromEvent(zap);
		if (details?.amount) totalAmount += details.amount;
	}

	return totalAmount;
}