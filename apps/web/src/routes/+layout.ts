import { configureDefaultNDK } from "$utils/ndk";
import { ndk } from "@kind0/ui-common";
import { get } from "svelte/store";

export const ssr = false;
export const prerender = false;

export async function load() {
    const $ndk = get(ndk);

    if ($ndk.explicitRelayUrls!.length === 0) {
        await configureDefaultNDK();
    }
}
