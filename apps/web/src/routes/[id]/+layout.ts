import { ndk } from "$stores/ndk";
import { NDKUser } from '@nostr-dev-kit/ndk';
import { nip05 } from 'nostr-tools';
import { get } from 'svelte/store';
import createDebug from 'debug';
import { vanityUrls } from '$utils/const.js';

const debug = createDebug('HL:user-layout');

export async function load({ params, fetch, data }) {
	const { id } = params;
	let user: NDKUser | undefined;
	const $ndk = get(ndk);

	debug(`user layout starting for ${id}: ${JSON.stringify(data)}`);

	if (vanityUrls[id]) {
		user = $ndk.getUser({ pubkey: vanityUrls[id] });
		return { user, npub: user.npub };
	}

	if (data?.pubkey) {
		user = $ndk.getUser({pubkey: data.pubkey});
		return { user, pubkey: data.pubkey };
	}

	if (id.startsWith('npub')) {
		user = new NDKUser({ npub: id });
		return { user, npub: id };
	}

	nip05.useFetchImplementation(async (url: string, options: any) => {
		options ??= {};
		options.cache = 'no-store';
		// set no-cors
		options.mode = 'no-cors';

		debug('fetching nip05', { url, options });
		const res = await fetch(url, options);
		debug('fetched nip05', { url, options, res });
		if (res.status === 404) {
			return {
				ok: false,
				status: 404,
				json: async () => {
					return {
						error: `User ${id} not found`
					};
				}
			};
		}
		return res;
	});

	let npub = ``;

	try {
		user = await $ndk.getUserFromNip05(id, true);
		if (user) {
			npub = user.npub;
		} else {
			console.log(`No user found for ${id}`);
		}
	} catch (e) {
		console.log(e, ` error`);
	}

	if (!npub) {
		npub = id;
	}

	return {
		user,
		id,
		npub
	};
}
