import { get as getStore } from "svelte/store";
import { ndk } from "@kind0/ui-common";
import NDKCacheAdapterDexie from "@nostr-dev-kit/ndk-cache-dexie";
import NDKRedisAdapter from "@nostr-dev-kit/ndk-cache-redis";
import { NDKPrivateKeySigner, NDKRelayAuthPolicies, NDKRelaySet } from "@nostr-dev-kit/ndk";
import createDebug from "debug";

const debug = createDebug("fans:ndk");

const RELAY = import.meta.env.VITE_RELAY;

export const defaultRelays = [ RELAY ];

// Relays we are going to send a request to check if we need to auth
const authRelays = [ RELAY ];

export function getDefaultRelaySet() {
    const $ndk = getStore(ndk)

    debug(`Getting default relay set`, {
        explicitRelayUrls: $ndk.explicitRelayUrls,
        stats: $ndk.pool.stats(),
    });

    const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
    for (const relay of relaySet.relays) {
        debug("default relay set: ", relay.url, relay.status, relay.connectionStats);
    }
    return relaySet;
}

export async function configureDefaultNDK() {
    const $ndk = getStore(ndk);
    $ndk.clientName = "getfaaans";
    $ndk.clientNip89 = "31990:4f7bd9c066a7b21d750b4e8dbf4440ef1e80c64864341550200b8481d530c5ce:1703282708172";
    $ndk.relayAuthDefaultPolicy = NDKRelayAuthPolicies.disconnect($ndk.pool);

    // add default relays
    for (const relay of defaultRelays) {
        const r = $ndk.addExplicitRelay(
            relay,
            NDKRelayAuthPolicies.signIn({ndk: $ndk}),
            false
        );
        r.trusted = true;

        if (authRelays.includes(relay)) {
            r.authRequired = true;
        }
        r.connect();
    }
    $ndk.addExplicitRelay('wss://purplepag.es');
    $ndk.addExplicitRelay('wss://relay.damus.io');
    $ndk.addExplicitRelay('wss://nos.lol');
}

export async function configureFeNDK() {
    const $ndk = getStore(ndk);
    $ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: "faaans" });
    $ndk.clientName = "getfaaans";

    await $ndk.connect(2000);
}

export async function configureBeNDK(privateKey: string, nodeFetch: typeof fetch) {
    const $ndk = getStore(ndk);
    $ndk.httpFetch = nodeFetch as typeof fetch;
    $ndk.debug.enabled = true;
    $ndk.signer = new NDKPrivateKeySigner(privateKey);
    // const redisAdapter = new NDKRedisAdapter({path: "redis://localhost:6379"});
    // const redisConnected = new Promise<void>((resolve) => {
    //     redisAdapter.redis.on("connect", () => {
    //         resolve();
    //     });
    // });
    Promise.all([
        $ndk.connect(2000),
        // redisConnected
    ]);

    // $ndk.cacheAdapter = redisAdapter;
    // console.log(`redis status: ${redisAdapter.redis.status}`);

    setInterval(() => {
        console.log(`NDK, pool stats`, $ndk.pool.stats());
        for (const relay of $ndk.pool.relays.values()) {
            const stat = relay.connectionStats;
            const subs = relay.activeSubscriptions();
            console.log(`[${relay.url}] stats (${stat.attempts} attempts, ${stat.success} successes -- ${subs.size} active subscriptions`);
            for (const [filter, subscriptions] of subs.entries()) {
                let text = `${JSON.stringify(filter)}`;

                if (subscriptions.length === 1 && subscriptions[0].subId) {
                    const subId = subscriptions[0].subId;
                    text = subId + ": " + text;
                } else {
                    text += ` (${subscriptions.length} subscriptions})`;
                }

                console.log(`\t${text}`);
            }
        }
    }, 30000);
}