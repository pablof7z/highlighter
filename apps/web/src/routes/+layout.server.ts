import "websocket-polyfill";
import { configureBeNDK } from '$utils/ndk';
import { ndk } from "@kind0/ui-common";
import { get } from "svelte/store";

const privateKey = process.env.RELAY_PRIVATE_KEY || "0d671b549ca4fc1b4fb042dd69751d26d024d88607b73fe3e22bf76e7b40da91";

if (!privateKey) {
    throw new Error("No private key provided");
}

const $ndk = get(ndk);
if (!$ndk.explicitRelayUrls || $ndk.explicitRelayUrls.length === 0) {
    configureBeNDK(privateKey);
}
