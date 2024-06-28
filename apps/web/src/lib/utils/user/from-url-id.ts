import { ndk } from "$stores/ndk";
import { vanityUrls } from "$utils/const";
import { NDKUser } from "@nostr-dev-kit/ndk";
import { nip05 } from "nostr-tools";
import { get } from "svelte/store";

const idToPubkeyMap = new Map<string, string>();

export async function getUserFromUrlId(id: string) {
	let user: NDKUser | undefined;
	const $ndk = get(ndk);

	if (vanityUrls[id]) {
		user = $ndk.getUser({ pubkey: vanityUrls[id] });
		return { user, npub: user.npub };
	}

	if (id.startsWith('npub')) {
		user = new NDKUser({ npub: id });
		return { user, npub: id };
	}

    if (idToPubkeyMap.has(id)) {
        console.log(`using idToPubkeyMap ${id}`);
        return {
			user: $ndk.getUser({ pubkey: idToPubkeyMap.get(id) }),
			id,
		}
    }

	nip05.useFetchImplementation(async (url: string, options: any) => {
		options ??= {};
		options.cache = 'no-store';
		// set no-cors
		options.mode = 'no-cors';

		const res = await fetch(url, options);
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
            idToPubkeyMap.set(id, user.pubkey);
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
