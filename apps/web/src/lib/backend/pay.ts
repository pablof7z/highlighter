import { getWalletForPubkey } from '$lib/server/wallet';
import { ndk } from "$stores/ndk";
import type { Hexpubkey } from '@nostr-dev-kit/ndk';
import { NDKNwc } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { get } from 'svelte/store';

const debug = createDebug('HL:payments:pay');

export async function getNwcString(pubkey: string) {
	const walletUri = await getWalletForPubkey(pubkey);

	if (!walletUri) {
		throw new Error('Wallet not connected');
	}

	return walletUri;
}

export async function sendPayment(invoice: string, pubkey: Hexpubkey): Promise<string> {
	const $ndk = get(ndk);
	const nwcUri = await getNwcString(pubkey);
	debug('sendPayment', {invoice, pubkey, nwcUri});

	let nwc: NDKNwc
	try {
		nwc = await $ndk.nwc(nwcUri, 5000);
	} catch (error) {
		debug('error connecting to wallet service', error);
		throw error;
	}

	nwc.getInfo().then((info) => {
		console.log('info', info);
	}).catch((error) => {
		console.error('error getting info', error);
		debug('error getting info', error);
	});

	nwc.getBalance().then((balance) => {
		console.log('balance', balance);
	}).catch((error) => {
		console.error('error getting balance', error);
		debug('error getting balance', error);
	});

	debug('sending payment');
	try {
		const res = await nwc.payInvoice(invoice);
		debug('payment sent', res);
		return res?.preimage || "";
	} catch (error) {
		debug('error sending payment', error);
		throw error;
	}
}
