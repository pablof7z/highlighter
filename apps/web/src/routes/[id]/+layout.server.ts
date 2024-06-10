import { vanityUrls } from '$utils/const';
import { NDKUser } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
// import { NIP05_FILE } from '$env/static/private';

// export const ssr = true;

const debug = createDebug('HL:user-layout');

export async function load({ params }) { 
	console.log('starting load')
	const { id } = params;
	let user: NDKUser | undefined;

	debug('server user layout starting', id);

	if (id.startsWith('npub')) {
		user = new NDKUser({ npub: id });
		console.log('finish load');
		return { pubkey: user.pubkey };
	}

	console.log('finish load');

	if (vanityUrls[id]) {
		return { pubkey: vanityUrls[id] };
	}

	// try {

	// 	console.log("Loading NIP05_FILE", NIP05_FILE)
	// 	const nip05file: any = await import(NIP05_FILE, { assert: { type: 'json' }});
	// 	console.log(nip05file);
	// 	const file2 = await read(NIP05_FILE).json();
	// 	console.log(file2);
	// 	const nip05 = JSON.parse(file2);
	// 	debug(`Loaded ${Object.keys(nip05.names).length} names from NIP05 file, looking for ${id}`)
	// 	const pubkey = nip05.names[id];
	// 	debug(`Found pubkey ${pubkey} for ${id}`);

	// 	if (pubkey) return { pubkey };
	// } catch(e: any) {
	// 	debug('Error reading NIP05 file', e.message??e);
	// 	console.trace(e);
	// }
}
