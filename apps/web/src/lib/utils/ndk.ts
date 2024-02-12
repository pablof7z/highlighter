import { get as getStore } from 'svelte/store';
import { ndk, newToasterMessage } from '@kind0/ui-common';
import NDKCacheAdapterDexie from '@nostr-dev-kit/ndk-cache-dexie';
import { NDKPrivateKeySigner, NDKRelay, NDKRelayAuthPolicies, NDKRelaySet } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { debugMode } from '$stores/session';

const debug = createDebug('HL:ndk');

const RELAY = import.meta.env.VITE_RELAY;

export const defaultVerifierPubkey = '73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63';
export const defaultRelays = [RELAY];
export const nip50Relays = ['wss://relay.noswhere.com', 'wss://relay.nostr.band'];

// Relays we are going to send a request to check if we need to auth
const authRelays = [RELAY];

export function getNip50RelaySet() {
	const $ndk = getStore(ndk);

	const relaySet = NDKRelaySet.fromRelayUrls(nip50Relays, $ndk);
	for (const relay of relaySet.relays) {
		debug('nip50 relay set: ', relay.url, relay.status, relay.connectionStats);
	}
	return relaySet;
}

export function getDefaultRelaySet() {
	const $ndk = getStore(ndk);

	debug(`Getting default relay set`, {
		explicitRelayUrls: $ndk.explicitRelayUrls,
		stats: $ndk.pool.stats()
	});

	const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
	for (const relay of relaySet.relays) {
		debug('default relay set: ', relay.url, relay.status, relay.connectionStats);
	}
	return relaySet;
}

export async function configureDefaultNDK(nodeFetch: typeof fetch) {
	const $ndk = getStore(ndk);
	$ndk.clientName = 'highlighter';
	$ndk.clientNip89 =
		'31990:73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63:1704502265408';
	$ndk.relayAuthDefaultPolicy = NDKRelayAuthPolicies.disconnect($ndk.pool);
	// $ndk.httpFetch = nodeFetch as typeof fetch;

	// add default relays
	for (const relay of defaultRelays) {
		const r = $ndk.addExplicitRelay(relay, NDKRelayAuthPolicies.signIn({ ndk: $ndk }), false);
		r.trusted = true;

		if (authRelays.includes(relay)) {
			r.authRequired = true;
		}
		r.connect();
	}
	$ndk.addExplicitRelay('wss://purplepag.es');
	$ndk.addExplicitRelay('wss://relay.damus.io');
	$ndk.addExplicitRelay('wss://nos.lol');
	$ndk.addExplicitRelay('wss://relay.noswhere.com');
	$ndk.addExplicitRelay('wss://relay.nostr.band');

	$ndk.connect();

	$ndk.pool.on('relay:ready', (relay) => {
		debug('relay ready', relay.url);
	});
	$ndk.pool.on('relay.disconnect', (relay) => {
		debug('relay disconnect', relay.url);
	});
}

export async function configureFeNDK() {
	const $ndk = getStore(ndk);
	const $debugMode = getStore(debugMode);
	// $ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: 'higlighter' });
	$ndk.clientName = 'highlighter';

	$ndk.pool.on("notice", (relay: NDKRelay, notice: string) => {
		debug('Relay notice', relay.url, notice);
		if ($debugMode) {
			newToasterMessage(`${relay.url}: ${notice}`);
		}
	});

	await $ndk.connect(2000);
}

export async function configureBeNDK(privateKey: string, nodeFetch: typeof fetch) {
	const $ndk = getStore(ndk);

	if ($ndk.explicitRelayUrls!.length === 0) {
		console.log('configureBeNDK: no explicit relays, configuring default');
		await configureDefaultNDK(nodeFetch);
	}

	// debug(`Configuring BE NDK`, { nodeFetch: !!nodeFetch });

	const fetchWrapper = async (url: string, options: RequestInit) => {
		console.log('fetchWrapper', url, options);
		try {
			return await fetch(url, options);
		} catch (error) {
			console.error('fetch error', error);
			throw error;
		}
	}

	$ndk.httpFetch = fetchWrapper as typeof fetch;

	// $ndk.httpFetch = nodeFetch as typeof fetch;
	$ndk.debug.enabled = true;
	$ndk.signer = new NDKPrivateKeySigner(privateKey);
	// const redisAdapter = new NDKRedisAdapter({path: "redis://localhost:6379"});
	// const redisConnected = new Promise<void>((resolve) => {
	//     redisAdapter.redis.on("connect", () => {
	//         resolve();
	//     });
	// });
	Promise.all([
		$ndk.connect(2000)
		// redisConnected
	]);

	// $ndk.cacheAdapter = redisAdapter;
	// console.log(`redis status: ${redisAdapter.redis.status}`);
}
