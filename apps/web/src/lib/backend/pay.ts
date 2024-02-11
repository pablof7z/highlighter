import db from '$lib/db';
import { webln } from '@getalby/sdk';
import type { Hexpubkey } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';

const debug = createDebug('HL:payments:pay');

async function getNwcString(pubkey: string) {
	const wallet = await db.walletConnect.findUnique({
		where: { pubkey }
	});

	if (!wallet) {
		throw new Error('Wallet not connected');
	}

	return wallet.uri;
}

export async function sendPayment(invoice: string, pubkey: Hexpubkey): Promise<string> {
	console.log('sendPayment', invoice, pubkey);
	let nwcUri = await getNwcString(pubkey);
	nwcUri = 'nostr+walletconnect://2c43c25ed6462e9a2cf91abd692080730abebc1af394402d56ce5625f59d31b1?relay=wss%3A%2F%2Frelay.mutinywallet.com%2F&secret=b8ba8a96802a254e63c2a723ae754ee74ecbfe312d8f028d7fd4f898704dadaf';
	debug(`Sending payment for ${pubkey}`, nwcUri);
	const nwc = new webln.NWC({ nostrWalletConnectUrl: nwcUri });

	debug('enabling nwc');
	const a = await nwc.enable();
	debug('ret', a)
	debug('connected', nwc.connected);

	// const balance = await nwc.getBalance();
	// console.log('balance', balance);
	debug('sending payment');
	const res = await nwc.sendPayment(invoice);
	debug('payment sent', res);
	return res;
}
