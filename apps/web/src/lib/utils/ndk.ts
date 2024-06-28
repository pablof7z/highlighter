import { get, get as getStore } from 'svelte/store';
import 'websocket-polyfill';
import { explicitRelayUrls, ndk, ndkRelaysWithAuth } from "$stores/ndk";
// import NDKRedisAdapter from '@nostr-dev-kit/ndk-cache-redis';
import { newToasterMessage } from '$stores/toaster';
import NDKCacheAdapterDexie from '@nostr-dev-kit/ndk-cache-dexie';
import NDKCacheAdapterNostr from "@nostr-dev-kit/ndk-cache-nostr";
import { NDKPrivateKeySigner, NDKRelay, NDKRelayAuthPolicies, NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { debugMode } from '$stores/session';
import { defaultRelays } from './const';
import NDKSigVerificationWorker from "@nostr-dev-kit/ndk/workers/sig-verification?worker";
// import NDKSqliteWorker from "@nostr-dev-kit/ndk-cache-sqlite-wasm/worker?worker";

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

	debug(`Getting default relay set %o`, defaultRelays);

	const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
	for (const relay of relaySet.relays) {
		debug('default relay set: ', relay.url, relay.status, relay.connectionStats);
	}
	return relaySet;
}

export async function configureDefaultNDK(nodeFetch: typeof fetch) {
	const $ndk = getStore(ndk);
	$ndk.httpFetch = nodeFetch as typeof fetch;

	// $ndk.devWriteRelaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);

	$ndk.explicitRelayUrls = [...explicitRelayUrls];
	
	for (const relay of defaultRelays) {
		debug('Adding default relay', relay);
		const r = $ndk.addExplicitRelay(relay, NDKRelayAuthPolicies.signIn({ ndk: $ndk }), false);
		r.trusted = true;
	}

	for (const relay of explicitRelayUrls) {
		debug('Adding explicit relay', relay);
		$ndk.addExplicitRelay(relay, undefined, false);
	}

	$ndk.pool.on('relay:auth', (relay) => {
		debug('relay auth', relay.url);
	});
	$ndk.pool.on('relay:disconnect', (relay) => {
		debug('relay disconnect', relay.url);
	});
}

export async function configureFeNDK() {
	const $ndk = getStore(ndk);
	const $debugMode = getStore(debugMode);
	$ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: 'HL13' });
	// const NDKCacheAdapterSqlite = await import('@nostr-dev-kit/ndk-cache-sqlite-wasm');
	// $ndk.cacheAdapter = new NDKCacheAdapterSqlite(
		// import.meta.env.DEV ?
			// new Worker(new URL("@nostr-dev-kit/ndk-cache-sqlite-wasm/worker?worker", import.meta.url), { type: 'module' })
			// new NDKSqliteWorker()
	// );

	const sigWorker = import.meta.env.DEV ?
		new Worker(new URL('@nostr-dev-kit/ndk/workers/sig-verification?worker', import.meta.url), { type: 'module' }) : new NDKSigVerificationWorker();

	$ndk.signatureVerificationWorker = sigWorker;

	$ndk.pool.on("notice", (relay: NDKRelay, notice: string) => {
		debug('Relay notice', relay.url, notice);
		if ($debugMode) {
			newToasterMessage(`${relay.url}: ${notice}`);
		}
	});

	$ndk.relayAuthDefaultPolicy = async (relay: NDKRelay, challenge: string) => {
		const $ndkRelaysWithAuth = get(ndkRelaysWithAuth);
		if (!($ndkRelaysWithAuth instanceof Map)) {
			ndkRelaysWithAuth.set(new Map());
		}

		if ($ndkRelaysWithAuth.get(relay.url) === undefined) {
			return new Promise<boolean>((resolve) => {
				$ndkRelaysWithAuth.set(relay.url, resolve);
			});
		} else {
			return $ndkRelaysWithAuth.get(relay.url) as boolean;
		}
	}
	
	debug("ndk connect on frontend")

	await $ndk.connect(1000);
}

export async function configureBeNDK(privateKey: string, nodeFetch: typeof fetch) {
	const $ndk = getStore(ndk);

	if ($ndk.explicitRelayUrls!.length === 0) {
		console.log('configureBeNDK: no explicit relays, configuring default');
		await configureDefaultNDK(nodeFetch);
	}

	debug('relay count' + $ndk.explicitRelayUrls!.length)

	// debug(`Configuring BE NDK`, { nodeFetch: !!nodeFetch });

	const fetchWrapper = async (url: string, options: RequestInit) => {
		console.trace('fetchWrapper', url, options);
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
	$ndk.cacheAdapter = new NDKCacheAdapterNostr({
		relayUrl: "ws://localhost:3002",
	})
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
