import { get as getStore } from 'svelte/store';
import { ndk, newToasterMessage } from '@kind0/ui-common';
import NDKCacheAdapterDexie from '@nostr-dev-kit/ndk-cache-dexie';
import { NDKPrivateKeySigner, NDKRelay, NDKRelayAuthPolicies, NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { userFollows, debugMode } from '$stores/session';
import { defaultRelays } from './const';

const debug = createDebug('HL:ndk');

export const nip50Relays = ['wss://relay.noswhere.com', 'wss://relay.nostr.band'];

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
	// $ndk.httpFetch = nodeFetch as typeof fetch;

	// add default relays
	for (const relay of defaultRelays) {
		const r = $ndk.addExplicitRelay(relay, NDKRelayAuthPolicies.signIn({ ndk: $ndk }), false);
		r.trusted = true;
	}
	$ndk.addExplicitRelay('wss://purplepag.es');
	$ndk.addExplicitRelay('wss://relay.damus.io');
	$ndk.addExplicitRelay('wss://nos.lol');
	$ndk.addExplicitRelay('wss://relay.noswhere.com');
	$ndk.addExplicitRelay('wss://relay.nostr.band');

	$ndk.connect(2000);

	$ndk.pool.on('relay:auth', (relay) => {
		debug('relay auth', relay.url);
	});
	$ndk.pool.on('relay:ready', (relay) => {
		debug('relay ready', relay.url);
	});
	$ndk.pool.on('relay:disconnect', (relay) => {
		debug('relay disconnect', relay.url);
	});
}

export async function configureFeNDK() {
	const $ndk = getStore(ndk);
	const $debugMode = getStore(debugMode);
	$ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: 'HL' });
	$ndk.clientName = 'highlighter';

	$ndk.pool.on("notice", (relay: NDKRelay, notice: string) => {
		debug('Relay notice', relay.url, notice);
		if ($debugMode) {
			newToasterMessage(`${relay.url}: ${notice}`);
		}
	});

	await $ndk.connect(2000);

	setTimeout(() => {
		const $userFollows = getStore(userFollows)
		$ndk.fetchEvents([
			{ kinds: [0], authors: Array.from($userFollows), limit: 1000 },
			{ kinds: [30023], authors: Array.from($userFollows), limit: 1000 }
		], { groupable: false, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY });
	}, 1000);
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
