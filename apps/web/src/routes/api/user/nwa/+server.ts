import { json } from '@sveltejs/kit';
import createDebug from 'debug';
import type { Session } from '../../../../app.js';
import { ndk } from '@kind0/ui-common';
import { get } from 'svelte/store';
import { NDKPrivateKeySigner, type Hexpubkey, type NDKEvent } from '@nostr-dev-kit/ndk';
import { creatorRelayPubkey } from '$utils/const.js';

const log = createDebug('HL:/api/user/nwa');

type Payload = {
	nwc: string;
};

const keys: Record<Hexpubkey, string> = {};

async function processNWAEvent(event: NDKEvent, signer: NDKPrivateKeySigner, pubkey: Hexpubkey, secret: string, userPubkey: Hexpubkey) {
	await event.decrypt(event.author, signer);
	const payload = JSON.parse(event.content);

	log(`payload`, payload);

	if (payload.secret !== secret) {
		log(`secret mismatch`, secret);
		return;
	}

	const url = new URL(`nostr+walletconnect://${pubkey}`);
	url.searchParams.set("relay", payload.relay);
	url.searchParams.set("secret", payload.secret);

	log(`nwc url`, url.toString());

	// const nwc = url.toString();

	// delete the old one
	// await db.walletConnect.deleteMany({ where: { pubkey } });

	// const a = await db.walletConnect.upsert({
	// 	where: { pubkey },
	// 	create: { pubkey: userPubkey, uri: nwc },
	// 	update: { uri: nwc }
	// });

	// log(a);
}

export async function GET({ locals }) {
	const { pubkey } = locals.session as Session;
	const $ndk = get(ndk);

	keys[pubkey] ??= NDKPrivateKeySigner.generate().privateKey!;

	const signer = new NDKPrivateKeySigner(keys[pubkey]);
	const user = await signer.user();

	const secret = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

	const url = new URL(`nostr+walletauth://${user.pubkey}`);
	url.searchParams.set("relay", "wss://relay.damus.io");
	url.searchParams.set("secret", secret);
	url.searchParams.set("required_commands", "pay_invoice");
	url.searchParams.set("identity", "73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63");

	const sub = $ndk.subscribe({ kinds: [33194], "#d": [user.pubkey] }, {});
	sub.on('event', async (event: NDKEvent) => {
		log(`received event`, event.rawEvent());
		try {
			await processNWAEvent(event, signer, user.pubkey, secret, pubkey);
		} finally {
			sub.stop();
		}
	});

	return json({ url: url.toString(), pubkey: user.pubkey });
}

export async function POST({ request, locals }) {
	const { pubkey } = locals.session as Session;
	const payload = await request.json();
	const { secret } = payload as Payload;
	const $ndk = get(ndk);
	const oneSecondAgo = Math.floor(Date.now() / 1000) - 5;

	log(`subscribing to events tagging ${creatorRelayPubkey} since ${oneSecondAgo}`);

	const sub = $ndk.subscribe({
		kinds: [33194],
		"#d": [creatorRelayPubkey],
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

				// const nwc = url.toString();

				// const a = await db.walletConnect.upsert({
				// 	where: { pubkey },
				// 	create: { pubkey, uri: nwc },
				// 	update: { uri: nwc }
				// });

				// log(a);

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
