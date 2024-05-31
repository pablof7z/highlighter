import { json } from '@sveltejs/kit';
import createDebug from 'debug';
import type { Session } from '../../../../app.js';
import { setWalletForPubkey } from '$lib/server/wallet.js';

const log = createDebug('HL:/api/user/nwc');

type Payload = {
	nwc: string;
};

export async function POST({ request, locals }) {
	const { pubkey } = locals.session as Session;
	const payload = await request.json();
	const { nwc } = payload as Payload;

	log('save nwc', payload);

	await setWalletForPubkey(pubkey, nwc);

	try {
		return json({ ok: true });
	} catch (error: any) {
		log(error);
		return json({ error: error.message }, { status: error.status });
	}
}
