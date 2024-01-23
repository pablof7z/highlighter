import db from '$lib/db';
import { json } from '@sveltejs/kit';
import createDebug from 'debug';
import type { Session } from '../../../../app.js';

const log = createDebug('shipyard:/api/posts');

type Payload = {
	nwc: string;
};

export async function POST({ request, locals }) {
	const { pubkey } = locals.session as Session;
	const payload = await request.json();
	const { nwc } = payload as Payload;

	log('save nwc', payload);

	const a = await db.walletConnect.upsert({
		where: { pubkey },
		create: { pubkey, uri: nwc },
		update: { uri: nwc }
	});

	console.log(a);

	try {
		return json({ ok: true });
	} catch (error: any) {
		log(error);
		return json({ error: error.message }, { status: error.status });
	}
}
