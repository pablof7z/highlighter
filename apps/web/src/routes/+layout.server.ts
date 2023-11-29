import "websocket-polyfill";
import { ndk } from "@kind0/ui-common";
import { get as getStore } from "svelte/store";
import NDKRedisAdapter from "@nostr-dev-kit/ndk-cache-redis";
import { NDKPrivateKeySigner, NDKRelay } from "@nostr-dev-kit/ndk";

const privateKey = process.env.RELAY_PRIVATE_KEY || "0d671b549ca4fc1b4fb042dd69751d26d024d88607b73fe3e22bf76e7b40da91";

if (!privateKey) {
    throw new Error("No private key provided");
}

const $ndk = getStore(ndk);
$ndk.cacheAdapter = new NDKRedisAdapter();
$ndk.pool.on("connect", () => console.log("Connected to NDK"));
$ndk.pool.addRelay(new NDKRelay('wss://relay.getfaaans.com'));
$ndk.pool.on("relay:connected", (r) => console.log('Connected to relay', r.url));
$ndk.connect(5000);
$ndk.signer = new NDKPrivateKeySigner(privateKey);