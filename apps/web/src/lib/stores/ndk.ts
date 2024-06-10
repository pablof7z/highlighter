import { writable } from 'svelte/store';
import NDK, { NDKRelayAuthPolicies } from '@nostr-dev-kit/ndk';
import NDKSvelte from '@nostr-dev-kit/ndk-svelte';
import { BROWSER, DEV } from 'esm-env';

// get relays from localstorage
let relays;

try {
    if (BROWSER) {
        relays = localStorage.getItem('relays');
    }
} catch (e) { /* empty */ }

let relayList: string[] = [];

if (relays) {
    relayList = JSON.parse(relays);
}

export const defaultRelays = [
    'wss://nos.lol/',
    'wss://relay.noswhere.com/',
    'wss://relay.primal.net/',
    'wss://relay.damus.io/',
    'wss://relay.nostr.band/',
    'wss://purplepag.es/',
];

// if (!relayList || !Array.isArray(relayList) || relayList.length === 0) {
    relayList = defaultRelays;
// }
    //

const _ndk: NDKSvelte = new NDKSvelte({
    explicitRelayUrls: relayList,
    enableOutboxModel: true,
}) as NDKSvelte;

_ndk.pool.blacklistRelayUrls.add("wss://relayer.fiatjaf.com/")
_ndk.pool.blacklistRelayUrls.add("wss://relay.nostr.info/")
_ndk.pool.blacklistRelayUrls.add("wss://nostr-01.bolt.observer/")

_ndk.clientName = 'highlighter';
_ndk.clientNip89 = '31990:73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63:1704502265408';

export const ndk = writable(_ndk);

const _bunkerNDK = new NDK({
    explicitRelayUrls: [
        'wss://relay.nsecbunker.com',
        'wss://relay.damus.io',
        'wss://relay.nsec.app',
    ],
});

export const bunkerNDK = writable(_bunkerNDK);
