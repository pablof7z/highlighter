import 'websocket-polyfill';
import { configureBeNDK } from '$utils/ndk';
import { ndk } from "$stores/ndk";
import { get } from 'svelte/store';
import { RELAY_PRIVATE_KEY } from '$env/static/private';

if (!RELAY_PRIVATE_KEY) {
	throw new Error('No private key provided');
}

// define load function
const $ndk = get(ndk);

if (!$ndk.explicitRelayUrls || $ndk.explicitRelayUrls.length === 0) {
	if (!$ndk.explicitRelayUrls || $ndk.explicitRelayUrls.length === 0) {
		await configureBeNDK(RELAY_PRIVATE_KEY, fetch);
	}
}