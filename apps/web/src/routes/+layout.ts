import { configureDefaultNDK } from '../lib/utils/ndk';
import { ndk } from "$stores/ndk";
import { get } from 'svelte/store';
// import process from 'process';

// const mobileBuild = !!process.env.MOBILE;

export const ssr = true; // !mobileBuild;
export const prerender = 'auto';
// export const trailingSlash = mobileBuild ? 'always' : 'ignore';

export async function load({ fetch }) {
	const $ndk = get(ndk);

	if ($ndk.explicitRelayUrls!.length === 0) {
		await configureDefaultNDK(fetch);
	}
}
