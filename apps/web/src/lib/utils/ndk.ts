import { get as getStore } from "svelte/store";
import { ndk } from "@kind0/ui-common";
import NDKCacheAdapterDexie from "@nostr-dev-kit/ndk-cache-dexie";
import NDKRedisAdapter from "@nostr-dev-kit/ndk-cache-redis";
import { NDKPrivateKeySigner, NDKRelayAuthPolicies, NDKRelaySet } from "@nostr-dev-kit/ndk";

export const defaultRelays = [
    'wss://relay.getfaaans.com',
    // 'wss://offchain.pub',
    // "wss://eden.nostr.land",
    // "ws://localhost:5577"
];

// Relays we are going to send a request to check if we need to auth
const authRelays = [
    // "ws://localhost:5577"
];

export function getDefaultRelaySet() {
    const $ndk = getStore(ndk)
    return NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
}

export async function configureDefaultNDK() {
    const $ndk = getStore(ndk);
    $ndk.clientName = "getfaaans";
    $ndk.relayAuthDefaultPolicy = NDKRelayAuthPolicies.disconnect($ndk.pool);
    $ndk.pool.on("relay:connect", (r) => console.log('Connect to relay', r.url));

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
    }
    $ndk.addExplicitRelay('wss://purplepag.es');
}

export async function configureFeNDK() {
    const $ndk = getStore(ndk);
    $ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: "faaans" });
    $ndk.clientName = "getfaaans";

    await $ndk.connect(2000);
}

export async function configureBeNDK(privateKey: string) {
    const $ndk = getStore(ndk);
    $ndk.debug.enabled = true;
    $ndk.signer = new NDKPrivateKeySigner(privateKey);
    const redisAdapter = new NDKRedisAdapter({path: "redis://localhost:6379"});
    const redisConnected = new Promise<void>((resolve) => {
        redisAdapter.redis.on("connect", () => {
            resolve();
        });
    });
    Promise.all([
        $ndk.connect(2000),
        redisConnected
    ]);

    $ndk.cacheAdapter = redisAdapter;
    console.log(`redis status: ${redisAdapter.redis.status}`);

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