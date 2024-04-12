import { NDKUser } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { NIP05_FILE } from '$env/static/private';
import * as fs from 'fs';

const debug = createDebug('HL:user-layout');

export async function load({ params }) {
	const { id } = params;
	let user: NDKUser | undefined;

	debug('user layout starting');

	if (id.startsWith('npub')) {
		user = new NDKUser({ npub: id });
		return { pubkey: user.pubkey };
	}

	try {
		const nip05 = JSON.parse(fs.readFileSync(NIP05_FILE, 'utf-8'));
		const pubkey = nip05.names[id];

		if (pubkey) return { pubkey };
	} catch { /**/ }
}
