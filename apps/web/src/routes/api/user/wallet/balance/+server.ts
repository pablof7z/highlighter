import 'websocket-polyfill';

import { json } from '@sveltejs/kit';
import createDebug from 'debug';
import { getNwcString, sendPayment } from '$lib/backend/pay.js';
import { ndk } from '@kind0/ui-common';
import { get } from 'svelte/store';
import type { Session } from '../../../../../app';
import { NDKNwc } from '@nostr-dev-kit/ndk';

const debug = createDebug('HL:/api/user/wallet/balance');

export async function GET({ locals }) {
	const { pubkey } = locals.session as Session;

    const $ndk = get(ndk);
	const nwcUri = await getNwcString(pubkey);

    const nwc = await NDKNwc.fromURI($ndk, nwcUri);
	try {
		await nwc.blockUntilReady(5000);
	} catch (error) {
		debug('error connecting to wallet service', error);
		throw error;
	}

    try {
        const balance = await nwc.getBalance()
        return json(balance.result);
    } catch (error: any) {
		debug('error getting balance', error);
        return json(error, { status: 400 });
	}
}
