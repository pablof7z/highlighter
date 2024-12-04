<script lang="ts">
	import { Button } from '$components/ui/button';
	import LnQrModal from '$modals/LnQrModal.svelte';
	import { ndk } from '$stores/ndk';
	import { openModal, closeModal } from '$utils/modal';
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu';
	import { CaretDown } from 'phosphor-svelte';
	import { NDKCashuWallet } from '@nostr-dev-kit/ndk-wallet';
	import { toast } from 'svelte-sonner';

	export let wallet: NDKCashuWallet;
	export let amount = 10000;

	let open = false;

	async function topUp(mint?: string) {
		const deposit = wallet.deposit(amount, mint);
		console.log('deposit', deposit);
		deposit.on('success', () => {
			toast('Deposit success');
			closeModal(LnQrModal);
		});
		const pr = await deposit.start();

		openModal(LnQrModal, { pr, satAmount: amount, title: 'Top up wallet' });
	}

	const mints = wallet.mints;

	function topUpFromAnyMint() {
		const randomMint = mints[Math.floor(Math.random() * mints.length)];
		topUp(randomMint);
	}
</script>

<DropdownMenu.Root bind:open>
	<Button
		class="!rounded-r-0 flex w-full flex-row items-center !px-0"
		{...$$props}
		on:click={topUpFromAnyMint}
	>
		<div class="flex-grow">Top Up</div>
		<DropdownMenu.Trigger class="flex translate-x-4 bg-black/10 p-4">
			<button class="w-fit" {...$$props}>
				<CaretDown />
			</button>
		</DropdownMenu.Trigger>
	</Button>
	<DropdownMenu.Content>
		<DropdownMenu.Group>
			{#each mints as mint}
				<DropdownMenu.Item on:click={() => topUp(mint)}>
					{mint}
				</DropdownMenu.Item>
			{/each}
		</DropdownMenu.Group>
	</DropdownMenu.Content>
</DropdownMenu.Root>
