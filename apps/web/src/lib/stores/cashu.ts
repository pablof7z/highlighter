import { getRelayListForUser, NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
import NDKSvelte from '@nostr-dev-kit/ndk-svelte';
import { NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import { NDKCashuToken } from '$utils/cashu/token';
import { NDKCashuWallet } from '$utils/cashu/wallet';
import { derived, get, writable } from 'svelte/store';
import { ndk } from './ndk';
import { CashuMint, CashuWallet, MeltQuoteResponse, Proof } from '@cashu/cashu-ts';
import currentUser from './currentUser';

export let walletMap = writable<Map<string, NDKCashuWallet>>(new Map());
export let wallets = derived(walletMap, $wallets => Array.from($wallets.values()));

export let walletTokens = writable<Map<string, NDKCashuToken[]>>(new Map());

export let userProofs = writable<Proof[]>([]);

export let walletBalance = derived(walletTokens, $walletTokens => {
    const balances = new Map<string, number>();

    for (const [walletId, tokens] of $walletTokens) {
        const balance = tokens.reduce((acc, token) => acc + token.amount, 0);
        balances.set(walletId, balance);
    }

    return balances;
});

export const activeWallet = derived(wallets, $wallets => {
    return $wallets[0];
});

export const defaultWalletBalance = derived([activeWallet, walletBalance], ([$activeWallet, $walletBalance]) => {
    if (!$activeWallet) return 0;
    return $walletBalance.get($activeWallet.dTag!) ?? 0;
})

export const activeWalletTokens = derived([activeWallet, walletTokens], ([$activeWallet, $walletTokens]) => {
    if (!$activeWallet) return [];
    return ($walletTokens.get($activeWallet.dTag!) ?? []) as NDKCashuToken[];
})

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

async function storeWalletEvent(event: NDKEvent) {
    const $walletMap = get(walletMap);
    const current = $walletMap.get(event.dTag!);
    // console.log('storing wallet event', event.rawEvent());
    if (current && current.created_at! >= event.created_at!) {
        return;
    }

    const wallet = await NDKCashuWallet.from(event);
    walletMap.update(wallets => {
        wallets.set(wallet.dTag!, wallet);
        return wallets;
    });

    walletTokens.update(tokens => {
        if (!tokens.has(wallet.dTag!)) {
            tokens.set(wallet.dTag!, []);
        }
        return tokens;
    });
}

// get the default wallet
async function getDefaultWallet() {
    const $currentUser = get(currentUser);
    const $wallets = get(wallets);
    if ($wallets[0]) return $wallets[0];

    const $ndk = get(ndk);

    const wallet = new NDKCashuWallet(get(ndk));
    if ($currentUser) wallet.pubkey = $currentUser.pubkey;
    wallet.dTag = "default";
    wallet.name = "Default Wallet";
    wallet.relays = (await getRelayListForUser($currentUser!.pubkey, $ndk)).relays;
    walletMap.update(wallets => {
        wallets.set(wallet.dTag!, wallet);
        return wallets;
    });

    return wallet;
}

async function storeTokenEvent(event: NDKEvent) {
    const token = NDKCashuToken.from(event);
    let walletId = token.tagValue("a")?.split(/:/)?.[2];

    if (!walletId) {
        const wallet = await getDefaultWallet();
        if (token.mint) wallet.mints = [ token.mint, ...wallet.mints ];
        const $walletMap = get(walletMap);
        $walletMap.set(wallet.dTag!, wallet);
        walletId = wallet.dTag!;
    }

    // console.log('storing token event', event.rawEvent(), walletId);

    // add this token to the wallet
    walletTokens.update(tokens => {
        const walletTokens = tokens.get(walletId) ?? [];

        // check if the token already exists
        const exists = walletTokens.find(t => t.id === token.id);
        if (exists) return tokens;
        
        walletTokens.push(token);
        tokens.set(walletId, walletTokens);
        return tokens;
    });
}

export function cashuInit(ndk: NDKSvelte, currentUser: NDKUser) {
    walletRelaySet = NDKRelaySet.fromRelayUrls([ "wss://nos.lol" ], ndk);

    const walletSub = ndk.subscribe([
        { kinds: [37375 as number], authors: [currentUser.pubkey] },
        { kinds: [7375 as number], authors: [currentUser.pubkey] }
    ], {
        subId: 'cashu-wallet',
        groupable: false,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    }, walletRelaySet);
    walletSub.on("event", async (event) => {
        if (event.kind === 37375) storeWalletEvent(event);
        else if (event.kind === 7375) await storeTokenEvent(event);
    });
}

export async function chooseProofs(amount: number, walletId: string, mint: string) {
    const $walletTokens = get(walletTokens);
    const tokens = $walletTokens.get(walletId) ?? [];
    const ret = [];
    const proofsToUse = [];
    const proofsToMove = [];
    const usedTokens = [];

    const wallet = new CashuWallet(new CashuMint(mint));

    
    let remaining = amount;
    
    for (const token of tokens) {
        if (token.mint !== mint) continue;
        
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

export async function payWithProofs(pr: string, amount: number, walletEvent?: NDKCashuWallet, zapRecipient?: NDKEvent | NDKUser) {
    const $activeWallet = get(activeWallet);
    walletEvent ??= $activeWallet;

    if (!walletEvent) {
        throw new Error('no wallet event');
    }

    const $ndk = get(ndk);
    let proofs: { proofsToUse: Proof[], proofsToMove: Proof[], usedTokens: NDKCashuToken[] } = { proofsToUse: [], proofsToMove: [], usedTokens: [] };
    let quote: MeltQuoteResponse | undefined | null;

    for (const mint of walletEvent.mints) {
        try {
            const wallet = new CashuWallet(new CashuMint(mint));
            quote = await wallet.meltQuote(pr);
            console.log('quote', quote);
            proofs = await chooseProofs(quote.amount, walletEvent.dTag!, mint);
        } catch (e) {
            console.error(e);
        }
    }

    if (!quote) {
        throw new Error('no quote');
    }

    if (proofs.proofsToUse.length === 0) {
        throw new Error('no proofs');
    }

    const mint = proofs.usedTokens[0].mint;
    if (!mint) {
        throw new Error('no mint');
    }
    const wallet = new CashuWallet(new CashuMint(mint));

    console.log('paying with proofs', proofs);

    
    const result = await wallet.payLnInvoice(pr, proofs.proofsToUse, quote);
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
    tokenEvent.mint = mint;
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

export async function checkTokenProofs(token: NDKCashuToken) {
    const mint = token.mint;
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