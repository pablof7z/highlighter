<script lang="ts">
	import { appMobileView } from "$stores/app";
	import { modal, modalState } from "$stores/layout";
	import { closeModal } from "$utils/modal";
	import { Block, Sheet } from "konsta/svelte";
	import { Modals, openModal } from "svelte-modals";
	import { fade } from "svelte/transition";
    
    let isPhone = $appMobileView;
	let modalOpen = false;

    $: if (!isPhone && $modal?.component) {
        openModal($modal.component as any, $modal.props);
		modalOpen = true;
    }

	$: if (!isPhone && modalOpen && !$modal?.component) {
		closeModal();
		modalOpen = false;
	}
</script>

{#if isPhone}
	<Sheet
		class="pb-safe w-full"
		opened={!!$modal}
		onBackdropClick={closeModal}
	>
		<Block>
			{#if $modal}
					<svelte:component this={$modal.component} {...$modal.props} />
				{/if}
		</Block>
	</Sheet>
{:else}
	<Modals>
		<div
			slot="backdrop"
			class="backdrop z-[51] fixed"
			class:hidden={$modalState !== "open"}
			on:click={closeModal}
			transition:fade={{ duration: 300 }}></div>
	</Modals>
{/if}

<style lang="postcss">
	.backdrop {
		position: fixed;
		top: 0;
		bottom: 0;
		right: 0;
		backdrop-filter: blur(10px);
		left: 0;
		background: rgba(0,0,0,0.50)
	}
</style>