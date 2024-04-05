import { ndk } from '@kind0/ui-common';
import { NDKUser } from '@nostr-dev-kit/ndk';
import { nip05 } from 'nostr-tools';
import { get } from 'svelte/store';
import createDebug from 'debug';
import { goto } from '$app/navigation';

const debug = createDebug('highlighter:user-layout');

export async function load({ params, fetch }) {
	const { id } = params;
	let user: NDKUser | undefined;

	debug('user layout starting');

	if (id.startsWith('npub')) {
		user = new NDKUser({ npub: id });
		return { user, npub: id };
	}

	nip05.useFetchImplementation(async (url: string, options: any) => {
		options ??= {};
		options.cache = 'no-store';

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
		const $ndk = get(ndk);
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
