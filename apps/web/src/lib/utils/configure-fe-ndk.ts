import { get as getStore } from "svelte/store";
import { ndk } from "@kind0/ui-common";
import NDKCacheAdapterDexie from "@nostr-dev-kit/ndk-cache-dexie";
import { NDKRelay } from "@nostr-dev-kit/ndk";

export function configureFeNDK() {
    const $ndk = getStore(ndk);
    $ndk.cacheAdapter = new NDKCacheAdapterDexie({ dbName: "faaans" });
    $ndk.clientName = "getfaaans";
    $ndk.pool.addRelay(new NDKRelay('ws://localhost:5577'));
    $ndk.connect();
}