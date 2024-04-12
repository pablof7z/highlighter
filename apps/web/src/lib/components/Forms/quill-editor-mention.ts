import {ndk} from '@kind0/ui-common';
import { NDKEvent, NDKRelaySet, profileFromEvent } from '@nostr-dev-kit/ndk';
import { get } from 'svelte/store';


export default async function(searchTerm, renderList) {
    const $ndk = get(ndk);

    const relaySet = NDKRelaySet.fromRelayUrls([ "wss://cache2.primal.net/v1" ], $ndk);

    const res = await $ndk.fetchEvents({
        cache: [ "user_search", {query: searchTerm, limit: 10} ]
    }, { closeOnEose: true }, relaySet);

    renderList(
        Array.from(res).map((event: NDKEvent) => {
            const profile = profileFromEvent(event);
            return {
                id: event.author.npub,
                avatar: profile.image,
                value: profile.displayName || profile.name
            }
        })
    );
}