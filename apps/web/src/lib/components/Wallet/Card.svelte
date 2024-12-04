<script lang="ts">
	import { currencyFormat } from '$utils/currency';
	import * as Card from '$components/ui/card';
	import { walletBalances, walletsBalance } from '$stores/wallet';
	import { nicelyFormattedMilliSatNumber, nicelyFormattedSatNumber, pluralize } from '$utils';
	import {
		NDKCashuWallet,
		NDKNWCGetInfoResult,
		NDKNWCWallet,
		NDKWallet,
		NDKWalletBalance
	} from '@nostr-dev-kit/ndk-wallet';
	import { DotsThree, Lightning } from 'phosphor-svelte';
	import Topup from './Topup.svelte';
	import { Button } from '$components/ui/button';
	import { wallet as defaultWallet } from '$stores/wallet';
	import Footer from '$components/Chat/Footer.svelte';

	export let wallet: NDKWallet;

	let isDefault: boolean = false;

	$: isDefault = $defaultWallet?.walletId === wallet.walletId;

	let balances: NDKWalletBalance[] | undefined;
	wallet.on('balance_updated', () => {
		balances = wallet.balance();
	});

	balances = wallet.balance() ?? [];

	let nwcWalletInfo: NDKNWCGetInfoResult | undefined;
	if (wallet instanceof NDKNWCWallet) {
		wallet.getInfo().then((info) => (nwcWalletInfo = info));
	}
</script>

<Card.Root class="bg-secondary/20 text-secondary-foreground w-64">
	<Card.Header class="flex flex-col gap-4 p-4">
		<Card.Title class="text-muted-foreground">
			{wallet.name ?? 'Wallet (' + wallet.type + ')'}
		</Card.Title>
		<Card.Description>
			<div class="text-foreground flex flex-row items-center gap-1 text-3xl font-bold">
				{#await wallet.balance()}
					<Lightning class="text-accent h-6 w-6" weight="fill" />
					Loading
				{:then balances}
					{#if balances}
						{#each balances as { amount, unit }}
							<div class="flex flex-row items-center">
								<Lightning class="text-accent h-6 w-6" weight="fill" />
								{#if unit === 'msats'}
									{nicelyFormattedMilliSatNumber(amount)}
								{:else}
									{currencyFormat(unit, amount)}
								{/if}
							</div>
						{/each}
					{/if}
				{/await}
			</div>
		</Card.Description>

		{#if nwcWalletInfo}
			<div class="flex flex-row items-center gap-2 text-sm">
				<div class="h-3 w-3 rounded-full" style="background-color: {nwcWalletInfo.color}" />
				{nwcWalletInfo.alias}
			</div>
		{/if}

		{#if wallet instanceof NDKCashuWallet}
			<div class="flex flex-row items-center gap-2">
				<div class="bg-secondary w-fit rounded-full p-2 px-4 text-base">
					{wallet.mints.length}
					{pluralize(wallet.mints.length, 'mint')}
				</div>

				<div class="bg-secondary flex w-fit flex-col rounded-full p-2 px-4 text-base">
					<div>{wallet.relays.length} {pluralize(wallet.relays.length, 'relay')}:</div>
					<!-- <div class="flex flex-row items-center">
                        {#each wallet.relays as relay}
                            <ConnectivityIndicator url={relay} />
                        {/each}
                    </div> -->
				</div>
			</div>
		{/if}
	</Card.Header>
	{#if wallet instanceof NDKCashuWallet}
		<Card.Content class="flex flex-row items-stretch gap-4 p-4 md:pt-0">
			<Topup {wallet} amount={1000} class="grow" />

			<Button
				variant="secondary"
				class="w-11 rounded-full p-0"
				href="/wallet/settings?id={wallet.walletId}"
			>
				<DotsThree size={24} />
			</Button>
		</Card.Content>
	{/if}
</Card.Root>
