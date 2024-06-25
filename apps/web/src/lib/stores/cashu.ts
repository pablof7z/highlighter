import type { NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
import NDKSvelte, { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
import { NDKRelaySet } from '@nostr-dev-kit/ndk';
import { NDKCashuToken } from '$utils/cashu/token';
import { NDKCashuWallet } from '$utils/cashu/wallet';
import { Readable, Writable, derived, get, writable } from 'svelte/store';
import { ndk } from './ndk';
import { Proof } from '@cashu/cashu-ts';

export let walletEvents: NDKEventStore<NDKCashuWallet>;
export let activeWalletEvent: Readable<NDKCashuWallet>;
export let walletTokens: Writable<Map<string, NDKCashuToken[]>> = writable(new Map());
export let userTokens: NDKEventStore<NDKCashuToken>;
export let userProofs: Readable<Proof[]>;

/**
 * Fetch the events that are tagged as token in the wallet
 */
async function updateWalletTokens(wallet: NDKCashuWallet) {
    const walletId = wallet.dTag!;
    const $ndk = get(ndk);
    console.log('fetching wallet events', wallet.mint);

    const tokenIds = wallet.tokenIds;
    console.log('token ids', tokenIds);
    if (tokenIds.length === 0) {
        console.log('no token ids to fetch');
        return;
    }
    
    const tokenEvents = await $ndk.fetchEvents({ ids: tokenIds });
    console.log('token events', tokenEvents);

    walletTokens.update(tokens => {
        tokens.set(
            walletId,
            Array.from(tokenEvents)
                .map(event => NDKCashuToken.from(event))
        );
        return tokens;
    });
}

export function cashuInit(ndk: NDKSvelte, currentUser: NDKUser) {
    const relaySet = NDKRelaySet.fromRelayUrls([ "ws://localhost:5577" ], ndk);
    walletEvents = ndk.storeSubscribe([
        { kinds: [37375 as number], authors: [currentUser.pubkey] }
    ], {
        subId: 'cashu-wallet',
        relaySet,
        onEose: () => {
            const $walletEvents = get(walletEvents);
            for (const wallet of $walletEvents) {
                updateWalletTokens(wallet);
            }
        }
    }, NDKCashuWallet);

    activeWalletEvent = derived(walletEvents, $walletEvents => {
        return $walletEvents[0];
    });

    userTokens = ndk.storeSubscribe({
        kinds: [7375 as number], authors: [currentUser.pubkey]
    }, { subId: 'cashu-tokens', relaySet }, NDKCashuToken);

    userProofs = derived(userTokens, $userTokens => {
        return $userTokens.reduce((proofs, token) => {
            return proofs.concat(token.proofs);
        }, [] as Proof[]);
    });
}
