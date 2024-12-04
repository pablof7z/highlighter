<script lang="ts">
	import NDKWalletService, { NDKCashuWallet, NDKNWCGetInfoResult, NDKNWCWallet, NDKWalletBalance, NDKWebLNWallet } from '@nostr-dev-kit/ndk-wallet';
	import RadioButton from '$components/Forms/RadioButton.svelte';
	import ModalShell from '$components/ModalShell.svelte';
	import { onDestroy, onMount } from 'svelte';
	import { NavigationOption } from '../../../app';
	import { ndk } from '$stores/ndk';
	import { NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
	import currentUser from '$stores/currentUser';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { Wallet } from 'lucide-svelte';
	import WalletItem from './WalletItem.svelte';
	import { activeWallet, WalletType } from '$stores/settings';
	import { walletInit } from '$stores/wallet';
	import NostrWalletConnect from './NostrWalletConnect.svelte';
	import { nicelyFormattedMilliSatNumber } from '$utils';
	import Card from '$components/Wallet/Card.svelte';

	export let walletType: WalletType = $activeWallet?.type ?? 'nip-60';
	export let walletId: string = $activeWallet?.id ?? 'nip60:create';

	let weblnAvailable = false;

	onMount(() => {
		weblnAvailable = !!window.webln;
	});

	async function webln() {
		const wallet = new NDKWebLNWallet();
		try {
			const balance = await wallet.balance();
		} catch (e) {
			console.error(e);
		}
	}

	async function nip60(event: NDKEvent) {
		const wallet = await NDKCashuWallet.from(event);
		if (!wallet) {
			alert('Wallet not found');
			return;
		}

		$activeWallet = { type: 'nip-60', id: wallet.walletId };
	}

	async function createNip60() {
		const wallet = new NDKCashuWallet($ndk);
		const random2Digits = Math.floor(Math.random() * 90) + 10;
		wallet.name = `HL Wallet ${random2Digits}`;
		wallet.relays = $ndk.pool.connectedRelays().map((r) => r.url);
		wallet.mints = ['https://testnut.cashu.space/'];
		const pub = await wallet.publish();
		console.log('published', pub);

		walletId = wallet.walletId;

		const service = new NDKWalletService($ndk);
		await service.setMintList(wallet);

		nip60(wallet.event);
	}

    let nwcFetching = false;
    let nwcWalletInfo: NDKNWCGetInfoResult | undefined;
    let nwcWalletBalance: NDKWalletBalance | undefined;

	async function nwcConnect() {
        nwcFetching = true;
		const wallet = new NDKNWCWallet($ndk);
		await wallet.initWithPairingCode(walletId);
        nwcFetching = false;

        wallet.updateBalance().then(() => {
            nwcWalletBalance = wallet.balance()?.[0];
        })

        nwcWalletInfo = await wallet.getInfo()
        console.log('nwcWalletInfo', nwcWalletInfo);

        nwcWallet = wallet;
	}

	async function cont() {
		if (walletType === 'nip-60') {
			if (walletId === 'create') {
				await createNip60();
			} else {
				const dTag = walletId;
				const event = $walletEvents!.find((e) => e.dTag === dTag);
				if (!event) {
					alert('Wallet not found');
				} else {
					nip60(event);
				}
			}

			$activeWallet = { type: 'nip-60', id: walletId };
		} else if (walletType === 'webln') {
			$activeWallet = { type: 'webln', id: 'webln' };
			webln();
		} else if (walletType === 'nwc') {
            if (nwcWallet) {
                $activeWallet = { type: 'nwc', id: walletId };
            } else {
                nwcConnect();
            }
		}
	}

	let actionButtons: NavigationOption[] = [];

    let nwcWallet: NDKNWCWallet | undefined;
	let walletEvents: NDKEventStore<NDKEvent> | undefined;
	let walletTokens: NDKEventStore<NDKEvent> | undefined;

	$: if (!walletEvents && $currentUser?.pubkey) {
		walletEvents = $ndk.storeSubscribe({
			kinds: [NDKKind.CashuWallet],
			authors: [$currentUser?.pubkey]
		});
		walletTokens = $ndk.storeSubscribe({
			kinds: [NDKKind.CashuToken],
			authors: [$currentUser?.pubkey]
		});
	}

	onDestroy(() => {
		walletEvents?.unsubscribe();
	});

	let value = `${walletType}:${walletId}`;

	$: if (value.startsWith('nip-60')) {
		[walletType, walletId] = value.split(':') as [WalletType, string];
	} else if (value === 'webln') {
		walletType = 'webln';
		walletId = 'webln';
	} else if (value === 'nwc') {
		walletType = 'nwc';
		if (!walletId.startsWith('nostr+walletconnect://')) walletId = '';
	}

    const backButton = { name: 'Back', fn: () => { nwcWallet = undefined; value = 'nip-60:create'; }, buttonProps: { variant: 'link' } }

	$: if (value === 'nwc') {
        if (nwcWallet) {
            actionButtons = [
                backButton,
                { name: 'Confirm', fn: cont, buttonProps: { variant: 'default', disabled: nwcFetching } }
            ];
        } else {
            actionButtons = [
                backButton,
                { name: 'Connect', fn: cont, buttonProps: { variant: 'default', disabled: nwcFetching } }
            ];
        }
	} else {
		actionButtons = [{ name: 'Continue', fn: cont, buttonProps: { variant: 'default' } }];
	}
</script>

<ModalShell title="Connect Wallet" {actionButtons}>
	{#if walletType === 'nwc'}
        {#if nwcWalletInfo}
            <Card wallet={nwcWallet} />
        {:else}
            <NostrWalletConnect bind:pairingCode={walletId} />
        {/if}
	{:else}
		<div class="flex flex-col gap-4">
			<RadioButton bind:currentValue={value} value="nip-60:create">
				New wallet

				<div slot="description">
					Create a new wallet accessible from any NIP-60 compatible application.
				</div>

				<Wallet slot="icon" />
			</RadioButton>

			{#if $walletEvents && $walletEvents.length > 0}
				{#each $walletEvents as walletEvent}
					<WalletItem event={walletEvent} bind:currentValue={value} />
				{/each}
			{/if}

			<RadioButton
				bind:currentValue={value}
				value="webln"
				class={weblnAvailable ? '' : 'pointer-events-none opacity-50'}
			>
				Use WebLN

				<div slot="description">
					{#if weblnAvailable}
						Use Lightning Network via your WebLN Extension.
					{:else}
						WebLN not detected in this browser.
					{/if}
				</div>
			</RadioButton>

			<RadioButton bind:currentValue={value} value="nwc">
				Nostr Wallet Connect

				<div slot="description">Use Nostr Wallet Connect to connect to your wallet.</div>
			</RadioButton>
		</div>
	{/if}
</ModalShell>
