import { configureDefaultNDK } from '../lib/utils/ndk';
import { ndk } from '@kind0/ui-common';
import { get } from 'svelte/store';

const mobileBuild = !!process.env.MOBILE;

export const ssr = false; // !mobileBuild;
export const prerender = 'auto';
export const trailingSlash = mobileBuild ? 'always' : 'ignore';

export async function load({ fetch }) {
	const $ndk = get(ndk);

	if ($ndk.explicitRelayUrls!.length === 0) {
		await configureDefaultNDK(fetch);
	}
}
