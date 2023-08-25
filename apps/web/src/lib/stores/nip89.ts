import { NDKAppHandlerEvent } from "@nostr-dev-kit/ndk";
import { get as getStore } from "svelte/store";
import ndk from './ndk';
import { jobRequestKinds } from "$utils";

const $ndk = getStore(ndk);

export const appHandlers = $ndk.storeSubscribe<NDKAppHandlerEvent>({
    kinds: [31990 as number],
    "#k": jobRequestKinds.map(j => j.toString())
}, { closeOnEose: false, subId: 'app-handlers' },
    NDKAppHandlerEvent
);