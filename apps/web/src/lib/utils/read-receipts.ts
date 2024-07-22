import {
	NDKEvent,
	NDKUser,
	type NDKTag,
	type NostrEvent,
	NDKPrivateKeySigner
} from '@nostr-dev-kit/ndk';
import { get } from 'svelte/store';
import createDebug from 'debug';
import { browser } from '$app/environment';
import currentUser from '$stores/currentUser';

let flushTimer: number | undefined = 10000;
let disabledReceipts = true;

if (browser) {
	const stored = localStorage.getItem('read-receipts-flush-timer')
	if (stored) flushTimer = parseInt(stored);

	const disabled = localStorage.getItem('read-receipts-disabled');
	if (disabled) disabledReceipts = true;
}

const queue: NDKTag[] = [];
let timeout: NodeJS.Timeout | undefined = undefined;

const d = createDebug('HL:read-receipts');

let signer: NDKPrivateKeySigner | undefined = NDKPrivateKeySigner.generate();

/**
 * Adds a kind:15 event tagging seen events.
 */
export function addReadReceipt(eventOrUser: NDKEvent | NDKUser): void {
	if (disabledReceipts) return;
	const $user = get(currentUser);

	if ($currentUser?.pubkey === eventOrUser.pubkey) return;

	if (eventOrUser instanceof NDKEvent) {
		const tags = eventOrUser.referenceTags();

		for (const tag of tags) {
			if (['a', 'e'].includes(tag[0])) queue.push(tag);
		}
	} else {
		queue.push(['p', eventOrUser.pubkey]);
	}

	d('Read receipt', queue);

	if (!timeout) {
		timeout = setTimeout(() => {
			timeout = undefined;
			flushReadReceipts();

			if (eventOrUser instanceof NDKEvent) {
				const event = eventOrUser as NDKEvent;
				// writeAppHandler(event.kind!, true);
			}
		}, flushTimer);
	}
}

/**
 * Tracks how long it takes to sign this events to assess whether
 * we are asking the user constantly and being annoying.
 */
const signatureTimes: number[] = [];

export async function flushReadReceipts(): Promise<void> {
	const $ndk = get(ndk);

	const tags = queue.splice(0, queue.length);

	if (timeout) {
		clearTimeout(timeout);
		timeout = undefined;
	}

	if (!tags.length) return;

	const event = new NDKEvent($ndk, {
		kind: 15,
		tags
	} as NostrEvent);

	const signStartTime = Date.now();

	try {
		await event.sign(signer);

		// Check how long it took to sign the event
		const totalSignTime = Date.now() - signStartTime;
		signatureTimes.push(totalSignTime);

		adjustFlushTimer();
	} catch (error) {
		// If we can't sign the event, use an anonymous signer
		// so we can still publish the event
		signer = NDKPrivateKeySigner.generate();
		await event.sign(signer);
	}

	// event.publish(getDefaultRelaySet());
}

function adjustFlushTimer() {
	if (!flushTimer) return;

	console.log('Adjusting flush timer', signatureTimes);

	// If it took 2 times longer than 3 seconds to sign events, increase the flush timer
	if (
		signatureTimes.length >= 2 && // Only start adjusting after 2 events
		signatureTimes.slice(-2).every((time) => time >= 3000) && // All 2 events took longer than 3 seconds
		signatureTimes.slice(-1)[0] >= 3000 // The last event took longer than 3 seconds
	) {
		flushTimer = Math.min(30000, (600000 + flushTimer * 2));
		if (browser) localStorage.setItem('read-receipts-flush-timer', flushTimer.toString());
	}
}
