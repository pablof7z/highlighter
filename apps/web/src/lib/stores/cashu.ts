import { NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
import NDKSvelte, { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
import { NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import { NDKCashuToken } from '$utils/cashu/token';
import { NDKCashuWallet } from '$utils/cashu/wallet';
import { Readable, Writable, derived, get, writable } from 'svelte/store';
import { ndk } from './ndk';
import { CashuMint, CashuWallet, Proof } from '@cashu/cashu-ts';

export let walletEvents: NDKEventStore<NDKCashuWallet>;
export let activeWalletEvent = writable<NDKCashuWallet | undefined>(undefined);
export let walletTokens: Writable<Map<string, NDKCashuToken[]>> = writable(new Map());
export let userTokens: NDKEventStore<NDKCashuToken>;
export let userProofs = writable<Proof[]>([]);
export let walletBalance = writable<number | undefined>(undefined);

/**
 * Fetch the events that are tagged as token in the wallet
 */
async function updateWalletTokens(wallet: NDKCashuWallet) {
    const walletId = wallet.dTag!;
    const $ndk = get(ndk);
    console.log('fetching wallet events', wallet.mint);

    const tokenIds = wallet.tokenIds;
    if (tokenIds.length === 0) {
        return;
    }
    
    const tokenEvents = await $ndk.fetchEvents({ ids: tokenIds });

    walletTokens.update(tokens => {
        tokens.set(
            walletId,
            Array.from(tokenEvents)
                .map(event => NDKCashuToken.from(event))
        );
        return tokens;
    });
}

export let walletRelaySet: NDKRelaySet;

export function cashuInit(ndk: NDKSvelte, currentUser: NDKUser) {
    walletRelaySet = NDKRelaySet.fromRelayUrls([ "wss://nos.lol" ], ndk);
    walletEvents = ndk.storeSubscribe([
        { kinds: [37375 as number], authors: [currentUser.pubkey] }
    ], {
        subId: 'cashu-wallet',
        relaySet: walletRelaySet,
        onEose: () => {
            const $walletEvents = get(walletEvents);
            activeWalletEvent.set($walletEvents[0]);
            for (const wallet of $walletEvents) {
                updateWalletTokens(wallet);
            }
        },
        autoStart: false
    }, NDKCashuWallet);

    userTokens = ndk.storeSubscribe({
        kinds: [7375 as number], authors: [currentUser.pubkey]
    }, { subId: 'cashu-tokens', relaySet: walletRelaySet, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY, autoStart: false }, NDKCashuToken);

    userTokens.subscribe(() => {
        const $userTokens = get(userTokens);
        const ret = $userTokens.reduce((proofs, token) => {
            return proofs.concat(token.proofs);
        }, [] as Proof[]);
        userProofs.set(ret);

        let balance = 0;
        for (const proof of ret) {
            balance += proof.amount;
        }
        walletBalance.set(balance);
    })

    walletEvents.startSubscription();
    userTokens.startSubscription();
}

export function chooseProofs(amount: number) {
    const $userTokens = get(userTokens);
    const ret = [];
    const proofsToUse = [];
    const proofsToMove = [];
    const usedTokens = [];
    let remaining = amount + 2;
    
    for (const token of $userTokens) {
        let tokenUsed = false;
        for (const proof of token.proofs) {
            if (remaining > 0) {
                proofsToUse.push(proof);
                remaining -= proof.amount;
                console.log('pushing proof', proof.amount, { remaining});
                tokenUsed = true;
                usedTokens.push(token);
            } else {
                proofsToMove.push(proof);
                console.log('marking proof as needing a new token event', proof.amount);
            }
        }

        if (remaining <= 0) break;
    }

    if (remaining > 0) {
        throw new Error('Not enough proofs');
    }

    console.log('chose proofs', {proofsToUse, proofsToMove, usedTokens});
    
    return {
        proofsToUse,
        proofsToMove,
        usedTokens
    };
}

export async function payWithProofs(pr: string, amount: number, wallet: CashuWallet, zapRecipient?: NDKEvent | NDKUser) {
    const $ndk = get(ndk);
    const proofs = chooseProofs(amount);
    console.log('paying with proofs', proofs);

    const result = await wallet.payLnInvoice(pr, proofs.proofsToUse);
    console.log('pay result', result);

    if (!result.isPaid) {
        return result;
    }

    proofs.usedTokens.forEach(token => {
        console.log('deleting token', token.id);
        token.delete();
    });

    const proofsToSave = proofs.proofsToMove;
    for (const change of result.change) {
        proofsToSave.push(change);
    }

    const tokenEvent = new NDKCashuToken($ndk);
    tokenEvent.proofs = proofsToSave;
    tokenEvent.publish(walletRelaySet);
    console.log('created new token event', tokenEvent.rawEvent);

    const payment = new NDKEvent($ndk);
    payment.kind = 7376;
    payment.tags.push(["pr", pr]);
    payment.tags.push(["amount", amount.toString()]);
    payment.tags.push(["preimage", result.preimage??""])
    if (zapRecipient) payment.tag(zapRecipient, "recipient");
    for (const tokens of proofs.usedTokens) {
        payment.tag(tokens);
    }
    payment.publish();

    return result;
}

export async function checkTokenProofs(token: NDKCashuToken, walletEvent: NDKCashuWallet) {
    const mint = walletEvent.mint;
    if (!mint) {
        throw new Error('no mint');
    }

    const wallet = new CashuWallet(new CashuMint(mint));
    const check = await wallet.checkProofsSpent(token.proofs);
    let unspent = token.proofs;

    for (const spent of check) {
        const id = spent.id;
        unspent = unspent.filter(p => p.id !== id);
    }

    if (unspent.length !== token.proofs.length) {
        if (unspent.length > 0) {
            const newToken = new NDKCashuToken(get(ndk));
            newToken.proofs = unspent;
            newToken.publish(walletRelaySet);
            console.log('created new token event', newToken.rawEvent());
        }

        token.delete();
        console.log('deleted token', token.id);

        return true;
    }

    return false;
}