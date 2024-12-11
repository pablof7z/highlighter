import NDKSvelte from "@nostr-dev-kit/ndk-svelte/svelte5";
import NDKCacheDexie from "@nostr-dev-kit/ndk-cache-dexie";
import { browser } from "$app/environment";

export const ndk = new NDKSvelte();
ndk.clientName = "highlighter";
ndk.clientNip89 = '31990:73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63:1704502265408';

if (browser) {
    ndk.cacheAdapter = new NDKCacheDexie({
        dbName: "highlighter-studio",
    });
}
