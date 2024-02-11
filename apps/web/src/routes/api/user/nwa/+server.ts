import db from '$lib/db';
import { json } from '@sveltejs/kit';
import createDebug from 'debug';
import type { Session } from '../../../../app.js';
import { ndk } from '@kind0/ui-common';
import { get } from 'svelte/store';
import { trustedPubkeys } from '$utils/login.js';
import type { NDKEvent } from '@nostr-dev-kit/ndk';

const log = createDebug('HL:/api/user/nwa');

type Payload = {
	nwc: string;
};

export async function POST({ request, locals }) {
	const { pubkey } = locals.session as Session;
	const payload = await request.json();
	const { secret } = payload as Payload;
	const $ndk = get(ndk);
	const oneSecondAgo = Math.floor(Date.now() / 1000) - 5;

	log(`subscribing to events tagging ${trustedPubkeys[0]} since ${oneSecondAgo}`);

	const sub = $ndk.subscribe({
		kinds: [33194],
		"#d": trustedPubkeys,
		since: oneSecondAgo
	});

	return new Promise((resolve, reject) => {
		sub.on('event', async (event: NDKEvent) => {
			log(`received event`, event.rawEvent());

			try {
				await event.decrypt();
				const payload = JSON.parse(event.content);

				log(`payload`, payload);

				if (payload.secret !== secret) {
					log(`secret mismatch`, secret);
					return;
				}

				const url = new URL(`nostr+walletconnect://${pubkey}`);
				url.searchParams.set("relay", payload.relay);
				if (payload.lug16) url.searchParams.set("lud16", payload.lug16);
				url.searchParams.set("secret", payload.secret);

				log(`nwc url`, url.toString());

				const nwc = url.toString();

				const a = await db.walletConnect.upsert({
					where: { pubkey },
					create: { pubkey, uri: nwc },
					update: { uri: nwc }
				});

				log(a);

				resolve(json({ ok: true }));
			} catch (e) {
				log(`error decrypting event`, e);
			} finally {
				sub.stop();
			}
		})
	});



	console.log(a);

	try {
		return json({ ok: true });
	} catch (error: any) {
		log(error);
		return json({ error: error.message }, { status: error.status });
	}
}
