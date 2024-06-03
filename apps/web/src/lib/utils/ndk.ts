import { get as getStore } from 'svelte/store';
import 'websocket-polyfill';
import { ndk } from "$stores/ndk";
import { newToasterMessage } from '$stores/toaster';
import NDKCacheAdapterDexie from '@nostr-dev-kit/ndk-cache-dexie';
import { NDKPrivateKeySigner, NDKRelay, NDKRelayAuthPolicies, NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { debugMode } from '$stores/session';
import { defaultRelays } from './const';
import NDKSigVerificationWorker from "@nostr-dev-kit/ndk/workers/sig-verification?worker";

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
	$ndk.httpFetch = nodeFetch as typeof fetch;
	$ndk.pool.blacklistRelayUrls.add("wss://relayer.fiatjaf.com/")
	$ndk.pool.blacklistRelayUrls.add("wss://relay.nostr.info/")
	$ndk.pool.blacklistRelayUrls.add("wss://nostr-01.bolt.observer/")

	// add default relays
	for (const relay of defaultRelays) {
		const r = $ndk.addExplicitRelay(relay, NDKRelayAuthPolicies.signIn({ ndk: $ndk }), false);
		r.trusted = true;
	}

	$ndk.addExplicitRelay('ws://localhost:5577', undefined, false);
	$ndk.addExplicitRelay('wss://purplepag.es/', undefined, false);
	$ndk.addExplicitRelay('wss://nos.lol/', undefined, false);
	$ndk.addExplicitRelay('wss://relay.noswhere.com/', undefined, false);
	$ndk.addExplicitRelay('wss://relay.primal.net/', undefined, false);
	$ndk.addExplicitRelay('wss://relay.damus.io/', undefined, false);
	$ndk.addExplicitRelay('wss://relay.nostr.band/', undefined, false);
	$ndk.addExplicitRelay('wss://relay.highlighter.com/', undefined, false);

	// $ndk.connect(2000);

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
	$ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: 'HL12' });
	$ndk.clientName = 'highlighter';

	const sigWorker = import.meta.env.DEV ?
		new Worker(new URL('@nostr-dev-kit/ndk/workers/sig-verification?worker', import.meta.url), { type: 'module' }) : new NDKSigVerificationWorker();

	$ndk.signatureVerificationWorker = sigWorker;

	$ndk.pool.on("notice", (relay: NDKRelay, notice: string) => {
		debug('Relay notice', relay.url, notice);
		if ($debugMode) {
			newToasterMessage(`${relay.url}: ${notice}`);
		}
	});

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
