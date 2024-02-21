import { sendPayment } from '$lib/backend/pay';
import { ndk } from '@kind0/ui-common';
import NDK, { NDKEvent, NDKSubscriptionStart, NDKUser, NDKZap, type Hexpubkey, type NostrEvent, type NDKTag } from '@nostr-dev-kit/ndk';
import { json, text } from '@sveltejs/kit';
import { get } from 'svelte/store';
import createDebug from 'debug';
import 'websocket-polyfill';
import { calculateSatAmountFromAmountTag } from '$utils/currency';
import { addToListOfSupporters, getTierNameFromSubscriptionEvent, recordValidSubscriptionPayment } from '$utils/subscriptions';
import { verifySignature, type Event } from 'nostr-tools';

const debug = createDebug('HL:/api/user/subscribe');

type Payload = {
	subscriptionEvent: string;
};

function getRecipient(event: NDKEvent): NDKUser {
	const $ndk = get(ndk);

	// if there are more than one p tag, throw
	const pTagCount = event.getMatchingTags('p').length;
	if (pTagCount !== 1) {
		throw new Error(`Found ${pTagCount} p tags, expected 1`);
	}

	const pTag = event.tagValue('p');
	return $ndk.getUser({ pubkey: pTag });
}

async function getPaymentRequest(event: NDKEvent): Promise<string | null> {
	const $ndk = get(ndk);

	const recipient = getRecipient(event);
	const amountTag = event.getMatchingTags('amount')[0];
	if (!amountTag) throw new Error('Amount not found');

	const satsAmount = await calculateSatAmountFromAmountTag(amountTag);
	const tierName = getTierNameFromSubscriptionEvent(event);
	let comment = `Highlighter subscription`;
	if (tierName) comment += ` to ${tierName}`;

	const zap = new NDKZap({
		ndk: $ndk,
		zappedEvent: event,
		zappedUser: recipient
	});

	let pr: string | null;

	try {
		pr = await zap.createZapRequest(satsAmount * 1000, comment);

		if (!pr) {
			throw new Error('Unable to generate a payment request');
		}

	} catch (error) {
		debug('error creating zap request', error);
		throw error;
	}

	debug('payment request', pr);

	return pr;
}

async function reportToClient(statusTags: NDKTag[], event: NDKEvent) {
	const $ndk = get(ndk);
	const e = new NDKEvent($ndk, {
		content: "",
		kind: 24001,
		tags: [
			[ "p", event.pubkey ],
			[ "e", event.id ],
			...statusTags
		]
	} as NostrEvent);
	await e.publish();
}

export async function POST({ request }) {
	const payload = await request.json();
	const { subscriptionEvent } = payload as Payload;
	// const response = await fetch("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");

	// return json(response.json());

	// await new Promise((resolve) => setTimeout(resolve, 2500));
	const $ndk = get(ndk);

	try {
		const event = new NDKSubscriptionStart($ndk, JSON.parse(subscriptionEvent));
		debug(event.rawEvent());

		// validate this event since it's not coming from a relay
		// and we need to make sure that the signature is valid
		if (!(await verifySignature(event.rawEvent() as Event))) {
			throw new Error('Invalid signature');
		}

		reportToClient([
			[ "status", "Fetching creator payment details" , "processing"]
		], event);

		const recipient = event.recipient;

		if (!recipient) {
			return text('Recipient not found', { status: 400 });
		}

		debug('getting payment request');
		const pr = await getPaymentRequest(event);
		debug('payment request', pr);

		if (!pr) {
			throw new Error('Unable to generate a payment request');
		}

		reportToClient([
			[ "status", "Fetching creator payment details" , "done"],
			[ "status", "Sending payment" , "processing"]
		], event);

		// const paymentResult = { mocked: 'yup!' };
		const paymentResult = await sendPayment(pr, event.pubkey);
		debug('payment result', paymentResult);

		reportToClient([
			[ "status", "Fetching creator payment details" , "done"],
			[ "status", "Sending payment" , "done"],
			[ "status", "Confirming payments" , "processing"]
		], event);

		await processNewSubscription(event, recipient, $ndk);

		reportToClient([
			[ "status", "Fetching creator payment details" , "done"],
			[ "status", "Sending payment" , "done"],
			[ "status", "Confirming payments" , "done"]
		], event);

		// return json({ success: true });

		return json(paymentResult);
	} catch (error: any) {
		console.log(JSON.stringify(error))
		debug('err', { error });
		return text(error.message ?? error.error?.message ?? JSON.stringify(error), { status: 400 });
	}
}

async function processNewSubscription(event: NDKSubscriptionStart, recipient: NDKUser, ndk: NDK) {
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
		})
	]);
}