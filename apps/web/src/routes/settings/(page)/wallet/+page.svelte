<script lang="ts">
	import { NDKCashuWalletKey } from '$utils/cashu/token.js';
	import { NDKRelaySet } from '@nostr-dev-kit/ndk';
	import Button from '$components/ui/button/button.svelte';
	import { derived } from 'svelte/store';
    import { CashuMint, CashuWallet } from '@cashu/cashu-ts';
	import currentUser from '$stores/currentUser.js';
	import { ndk } from '$stores/ndk.js';
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { Input } from '$components/ui/input';
	import { NDKCashuToken } from '$utils/cashu/token';
    import { NDKCashuWallet } from '$utils/cashu/wallet';
	import { activeWalletEvent } from '$stores/cashu.js';

    const myMints = $ndk.storeSubscribe([
        { kinds: [38000 as number], authors: [$currentUser.pubkey]},
    ]);
    
    const otherMintRecommendations = $ndk.storeSubscribe([
        { kinds: [38000 as number] } //, authors: Array.from($userFollows)},
    ]);

    const relaySet = NDKRelaySet.fromRelayUrls([
        "ws://localhost:5577"
    ], $ndk);

    const mintRecs = derived(otherMintRecommendations, ($otherMintRecommendations) => {
        const mintRefs: Record<string, number> = {};

        for (const mintRec of $otherMintRecommendations) {
            for (const aTag of mintRec.getMatchingTags("a")) {
                const [_, mintRef] = aTag;
                mintRefs[mintRef] = (mintRefs[mintRef] || 0) + 1;
            }
        }

        return mintRefs;
    });

    let mint: string = "https://stablenut.umint.cash";
    let wallet: CashuWallet;

    $: if (!wallet && $activeWalletEvent?.mint) {
        wallet = new CashuWallet(new CashuMint($activeWalletEvent.mint));
    }

    async function receive() {
        console.log('wallet', wallet);
        if (!wallet) {
            wallet = new CashuWallet(new CashuMint(mint));
        }

        const token = prompt("Enter token");

        if (!token) return;

        console.log({token})
        const recv = await wallet.receive(token);
        console.log('token', recv)

        const event = new NDKCashuToken($ndk);
        event.proofs = recv;
        event.wallet = $activeWalletEvent;
        await event.sign();
        event.publish();

        const walletEvent = NDKCashuWallet.from($activeWalletEvent);
        walletEvent.addToken(event);
        await walletEvent.publishReplaceable(relaySet);

        console.log('active wallet event', walletEvent.rawEvent());

        const keysEvent = new NDKCashuWalletKey($ndk);
        keysEvent.keys = wallet.keys;
        keysEvent.wallet = $activeWalletEvent;
        keysEvent.publishReplaceable(relaySet);

        console.log('keys', wallet.keys);
    }

    async function createWallet() {
        const w = new CashuWallet(new CashuMint(mint));
        let walletEvent: NDKCashuWallet;
        
        if ($activeWalletEvent) {
            walletEvent = NDKCashuWallet.from($activeWalletEvent);
        } else {
            walletEvent = new NDKCashuWallet($ndk);
            walletEvent.dTag = "dhckj6m5qny3iuwg";
            walletEvent.mint = mint;
        }
        walletEvent.relays = ["ws://localhost:5577"];

        try {
            const p = await walletEvent.publishReplaceable(relaySet);
        } catch (e) {
            console.error('error publishing wallet', e?.relayErrors);
            return;
        }

        wallet = w;

        // const walletKeyEvent = new NDKCashuWalletKey($ndk);
        // walletKeyEvent.keys = w.keys;
        // walletKeyEvent.wallet = walletEvent;
        // await walletKeyEvent.publish(relaySet);
    }
</script>

<PageTitle title="Wallet" />

{#if !wallet || true}
    <Input bind:value={mint} placeholder="Preferred mint" />

    <Button size="lg" on:click={createWallet}>
        Create Wallet
    </Button>
{/if}
    
{#if $activeWalletEvent}
    <Button size="lg" on:click={receive}>
        Receive
    </Button>

    {#await $activeWalletEvent.proofs()}
        <p>Getting proofs</p>
    {:then proofs}
        {#await $activeWalletEvent.balance() then balance}
            balance: {balance}
        {:catch e}
            {e.message}
        {/await}
        <!-- <pre>{JSON.stringify(proofs, null, 4)}</pre> -->
    {:catch error}
        <p>{error.message}</p>
    {/await}
{/if}

<!-- {#each $userTokens as token}
    <pre>{JSON.stringify(token.rawEvent(), null, 4)}</pre>
{/each} -->