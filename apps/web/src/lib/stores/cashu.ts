import { getRelayListForUser, NDKEvent, NDKEventId, NDKPrivateKeySigner, NDKUser } from '@nostr-dev-kit/ndk';
import NDKSvelte from '@nostr-dev-kit/ndk-svelte';
import { NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
import { NDKCashuToken } from '$utils/cashu/token';
import { NDKCashuWallet } from '$utils/cashu/wallet';
import { derived, get, writable } from 'svelte/store';
import { ndk } from './ndk';
import { CashuMint, CashuWallet, MeltQuoteResponse, Proof } from '@cashu/cashu-ts';
import currentUser from './currentUser';
import { toast } from 'svelte-sonner';
import { receiveCashuZap } from '$utils/zap';

export let walletMap = writable<Map<string, NDKCashuWallet>>(new Map());
export let wallets = derived(walletMap, $wallets => Array.from($wallets.values()));

/**
 * This is the real store that holds the tokens for each wallet.
 * We don't want to expose this store directly, since it will include recently used
 * tokens.
 */
export let _walletTokens = writable<Map<string, NDKCashuToken[]>>(new Map());

/**
 * This is the store that keeps tracks of recently-used tokens that should not be
 * used.
 */
export let deletedTokens = writable<Set<NDKEventId>>(new Set());

/**
 * This store keeps track of wallet tokens that can be used.
 */
export let walletTokens = derived([_walletTokens, deletedTokens], ([$walletTokens, $deletedTokens]) => {
    const tokens = new Map<string, NDKCashuToken[]>();

    for (const [walletId, walletTokens] of $walletTokens) {
        tokens.set(walletId, walletTokens.filter(token => !$deletedTokens.has(token.id)));
    }

    return tokens;
});

export let userProofs = writable<Proof[]>([]);

export let walletBalance = derived(walletTokens, $walletTokens => {
    const balances = new Map<string, number>();

    for (const [walletId, tokens] of $walletTokens) {
        const balance = tokens.reduce((acc, token) => acc + token.amount, 0);
        balances.set(walletId, balance);
    }

    return balances;
});

export let mintBalances = derived(walletTokens, $walletTokens => {
    const balances = new Map<string, number>();

    for (const [walletId, tokens] of $walletTokens) {
        for (const token of tokens) {
            const mint = token.mint;
            if (!mint) continue;
            const balance = balances.get(mint) ?? 0;
            balances.set(mint, balance + token.amount);
        }
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

    _walletTokens.update(tokens => {
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

    _walletTokens.update(tokens => {
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
    _walletTokens.update(tokens => {
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
    walletRelaySet = NDKRelaySet.fromRelayUrls([ "wss://relay.damus.io", "wss://relay.nostr.band" ], ndk);

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

    const cashuZapSub = ndk.subscribe([
        { kinds: [7377 as number], "#p": [currentUser.pubkey] },
        { kinds: [7378 as number], authors: [currentUser.pubkey] }
    ], {
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
        subId: 'cashu-zaps',
    });

    // Tracks the cashu-zaps we have already (n)acked
    let reactedZapEvents = new Set<NDKEventId>();
    cashuZapSub.on("event", async (event: NDKEvent) => {
        // track all the zap events we have reacted to
        if (event.kind === 7378) { event.getMatchingTags("e").forEach(([_, id]) => reactedZapEvents.add(id)); return }


        console.log('signer' ,ndk.signer)

        if (ndk.signer instanceof NDKPrivateKeySigner) {
            try {
                console.log('receiving zap', event.rawEvent());
                const tokenEvent = await receiveCashuZap(event, ndk.signer, ndk);
                console.log('received zap', tokenEvent.rawEvent());
                const wallet = get(activeWallet);
                const relaySet = NDKRelaySet.fromRelayUrls(wallet.relays, ndk);
                console.log('publishing to relay set', relaySet);
                tokenEvent.tag(wallet);
                tokenEvent.publish(relaySet)
                const amount = tokenEvent.amount;
                toast.success("Zap claimed " + amount);
            } catch (e) {
                console.error('could not claim zap', e);
                // toast.error("We received a zap but we can't claim it: " + e.message);
            }
        } else {
            toast.error("We received a zap but we can't claim it; you need to login with your nsec")
        }
    });
}

export async function chooseProofs(amount: number, walletId: string, mint: string) {
    const $walletTokens = get(walletTokens);
    const tokens = $walletTokens.get(walletId) ?? [];
    const ret = [];
    const proofsToUse = [];
    const proofsToMove = [];
    const usedTokens = [];

    console.log('wallet keys', $walletTokens.keys());

    console.log('choosing proofs', { amount, walletId, mint, tokens });

    let remaining = amount;
    
    for (const token of tokens) {
        console.log('checking token', { tokenMint: token.mint, requiredMint: mint }, token.id, token.amount, token.proofs.length);
        if (token.mint !== mint) continue;
        
        let tokenUsed = false;
        for (const proof of token.proofs) {
            if (remaining > 0) {
                proofsToUse.push(proof);
                remaining -= proof.amount;
                // console.log('pushing proof', proof.amount, { remaining});
                tokenUsed = true;
                usedTokens.push(token);
            } else {
                proofsToMove.push(proof);
                // console.log('marking proof as needing a new token event', proof.amount);
            }
        }

        if (remaining <= 0) break;
    }

    if (remaining > 0) {
        throw new Error('Not enough proofs' + remaining + " " + amount);
    }

    // console.log('chose proofs', {proofsToUse, proofsToMove, usedTokens});
    
    return {
        proofsToUse,
        proofsToMove,
        usedTokens
    };
}

type ProofsCombinaion = {
    proofsToUse: Proof[],
    proofsToMove: Proof[],
    usedTokens: NDKCashuToken[]
}

async function chooseProofsFromMintForPaymentRequest(
    pr: string,
    mint: string,
    walletId: string
) {
    let proofs: ProofsCombinaion = { proofsToUse: [], proofsToMove: [], usedTokens: [] };
    let quote: MeltQuoteResponse | undefined | null;
    
    try {
        const wallet = new CashuWallet(new CashuMint(mint));
        quote = await wallet.meltQuote(pr);
        proofs = await chooseProofs(quote.amount, walletId, mint);
    } catch (e) {
        // console.log(`mint ${mint} could not be used for this payment request`, e.message);
        return undefined;
    }

    return { mint, proofs, quote };
}

export async function payWithProofs(pr: string, amount: number, walletEvent?: NDKCashuWallet, zapRecipient?: NDKEvent | NDKUser) {
    const $activeWallet = get(activeWallet);
    walletEvent ??= $activeWallet;

    console.log('paying with wallet', walletEvent.dTag);

    if (!walletEvent) {
        throw new Error('no wallet event');
    }

    const $ndk = get(ndk);
    let proofs: ProofsCombinaion = { proofsToUse: [], proofsToMove: [], usedTokens: [] };
    let quote: MeltQuoteResponse | undefined | null;
    let mint: string | undefined;

    await new Promise<void>((resolve, reject) => {
        for (const m of walletEvent.mints) {
            console.log('trying mint', m, "out of mints", walletEvent.mints.length)
            chooseProofsFromMintForPaymentRequest(pr, m, walletEvent.dTag!).then(result => {
                if (result) {
                    proofs = result.proofs;
                    quote = result.quote;
                    mint = result.mint;
                    console.log('result', mint, proofs, quote);
                    resolve();
                } else {
                    console.log('no result');
                }
            });
        }
    });

    if (!quote) { throw new Error('no quote'); }
    if (proofs.proofsToUse.length === 0) { throw new Error('no proofs'); }
    if (!mint) { throw new Error('no mint'); }

    const wallet = new CashuWallet(new CashuMint(mint));

    console.log('paying with proofs', proofs);
    
    const result = await wallet.payLnInvoice(pr, proofs.proofsToUse, quote);
    console.log('pay result', result);

    if (!result.isPaid) {
        return result;
    }

    await rollOverProofs(proofs, result.change, mint);
    await recordPayment(pr, amount, result, proofs, zapRecipient);

    return result;
}

/**
 * Deletes and creates new events to reflect the new state of the proofs
 */
export async function rollOverProofs(
    proofs: ProofsCombinaion,
    changes: Proof[],
    mint: string,
) {
    const $ndk = get(ndk);
    
    proofs.usedTokens.forEach(token => {
        console.log('deleting token', token.id);
        deletedTokens.update(set => {
            set.add(token.id);
            return set;
        });
        token.delete();
    });

    const proofsToSave = proofs.proofsToMove;
    for (const change of changes) {
        proofsToSave.push(change);
    }

    const tokenEvent = new NDKCashuToken($ndk);
    tokenEvent.proofs = proofsToSave;
    tokenEvent.mint = mint;
    tokenEvent.publish(walletRelaySet);
    console.log('created new token event', tokenEvent.rawEvent);
}

export async function recordPayment(
    pr: string,
    amount: number,
    result: any,
    proofs: ProofsCombinaion,
    zapRecipient?: NDKEvent | NDKUser
) {
    const $ndk = get(ndk);
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