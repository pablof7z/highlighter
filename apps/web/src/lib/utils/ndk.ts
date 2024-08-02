import { get, get as getStore } from 'svelte/store';
import 'websocket-polyfill';
import { explicitRelayUrls, ndk } from "$stores/ndk";
import { ndkRelaysWithAuth } from "$stores/auth-relays.js";
// import NDKRedisAdapter from '@nostr-dev-kit/ndk-cache-redis';
import NDKCacheAdapterDexie from '@nostr-dev-kit/ndk-cache-dexie';
// import NDKCacheAdapterNostr from "@nostr-dev-kit/ndk-cache-nostr";
import { NDKEvent, NDKKind, NDKPrivateKeySigner, NDKPublishError, NDKRelay, NDKRelayAuthPolicies, NDKRelaySet, NDKSubscriptionCacheUsage, NDKUser } from '@nostr-dev-kit/ndk';
import createDebug from 'debug';
import { debugMode } from '$stores/session';
import { defaultRelays } from './const';
import NDKSigVerificationWorker from "@nostr-dev-kit/ndk/workers/sig-verification?worker";
import { toast } from 'svelte-sonner';
import NDKSvelte from '@nostr-dev-kit/ndk-svelte';
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
	console.log('setting default policy localhost')
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
	$ndk.on('event:publish-failed', (event: NDKEvent, error: NDKPublishError) => {
		debug('event publish failed', event.rawEvent(), error);
		let msg = error?.relayErrors ?? error.message
		toast.error(`Failed to publish event: ${msg}`);
	});
}

export async function configureFeNDK() {
	const $ndk = getStore(ndk);
	const $debugMode = getStore(debugMode);
	$ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: 'HL14' });
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
			toast.warning(`${relay.url}: ${notice}`);
		}
	});

	/**
	 * Default auth policy for non-explicit relays
	 */
	$ndk.relayAuthDefaultPolicy = async (relay: NDKRelay, challenge: string) => {
		const $ndkRelaysWithAuth = get(ndkRelaysWithAuth);
		if (!($ndkRelaysWithAuth instanceof Map)) {
			ndkRelaysWithAuth.set(new Map());
		}

		return true;

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
	// $ndk.cacheAdapter = new NDKCacheAdapterNostr({
	// 	relayUrl: "ws://localhost:3002",
	// })
	// const redisAdapter = new NDKRedisAdapter({path: "redis://localhost:6379"});
	// const redisConnected = new Promise<void>((resolve) => {
	//     redisAdapter.redis.on("connect", () => {
	//         resolve();
	//     });
	// });
	Promise.all([
		$ndk.connect(2000)
		// redisConnected
	]).then(() => {
		debug('connected');
	}).catch((error) => {
		console.trace('error connecting', error);
	});

	// $ndk.cacheAdapter = redisAdapter;
	// console.log(`redis status: ${redisAdapter.redis.status}`);

	background();
}

async function background() {
	const d = debug.extend('background');
	const $ndk = get(ndk);
	d('starting background');

	const relayUrl = import.meta.env.VITE_RELAY;
	const myPubkey = await (await $ndk.signer?.user())?.pubkey;

	d('relayUrl', relayUrl);
	d('myPubkey', myPubkey);

	if (!myPubkey || !relayUrl) {
		throw new Error('missing myPubkey or relayUrl');
	}

	const groups = $ndk.subscribe(
		{ kinds: [ NDKKind.GroupAdmins ], "#p": [myPubkey] }
	)

	groups.on("event", (event: NDKEvent) => {
		if (!event.dTag) {
			d('no dTag', event.rawEvent());
			return;
		}
		
		d('monitoring group', event.dTag);
		const monitor = $ndk.subscribe(
			{ kinds: [7001, 9021], "#h": [event.dTag] }
		)

		monitor.on("event", async (event: NDKEvent) => {
			d("event", event.rawEvent())
			await checkForZap($ndk, event.author, event.dTag!)
		});
	});
}

async function checkForZap(
	ndk: NDKSvelte,
	sender: NDKUser,
	groupId: string
): Promise<boolean> {
	const zaps = await ndk.fetchEvents([
		{ kinds: [ NDKKind.Nutzap ], authors: [sender.pubkey], "#h": [groupId] }
	])

	if (zaps.size === 0) {
		console.log("No zaps found")
		return false;
	}

	console.log("Found zaps", Array.from(zaps).map(z => z.rawEvent()))

	return true;
}