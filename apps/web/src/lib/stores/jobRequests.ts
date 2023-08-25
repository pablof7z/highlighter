import { NDKDVMRequest, NDKEvent } from "@nostr-dev-kit/ndk";
import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
import { get as getStore } from "svelte/store";
import ndk from './ndk';
import { currentUser } from "./current-user";
import { jobRequestKinds } from "$utils";

const $ndk = getStore(ndk);

export let userJobRequests: NDKEventStore<NDKDVMRequest> | undefined = undefined;
export let userTaggedEvents: NDKEventStore<NDKEvent> | undefined = undefined;

export function initJobRequests() {
    const $currentUser = getStore(currentUser);

    console.log('initJobRequests');

    if (!$currentUser) {
        throw new Error("Current user not initialized");
    }

    userJobRequests = $ndk.storeSubscribe(
        { kinds: jobRequestKinds, authors: [$currentUser.pubkey], limit: 100 },
        { closeOnEose: false, subId: 'user-job-requests' },
        NDKDVMRequest
    );

    userTaggedEvents = $ndk.storeSubscribe({
        kinds: [ 7000 ],
        "#p": [ $currentUser.pubkey ],
        since: Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 7,
        limit: 100
    }, { closeOnEose: false, subId: 'user-tagged-events' });
}
