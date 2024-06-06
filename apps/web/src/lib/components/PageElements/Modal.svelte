<script lang="ts">
	import { appMobileView } from "$stores/app";
	import { modal, modalState } from "$stores/layout";
	import { closeModal } from "$utils/modal";
	import { Modals, openModal, closeModal as closeModalReal } from "svelte-modals";
	import { fade } from "svelte/transition";
	import * as Drawer from "$lib/components/ui/drawer";
</script>

{#if $appMobileView}
	<Drawer.Root open={!!$modal}>
		<Drawer.Content class="max-h-[calc(100vh-44px)]">
			{#if $modal}
				<svelte:component this={$modal.component} {...$modal.props} />
			{/if}
		</Drawer.Content>
	</Drawer.Root>
	<!-- <Sheet
		class="pb-safe w-full max-h-[calc(100vh-44px)]"
		onBackdropClick={closeModal}
	>
		{#if $modal}
			
		{/if}
	</Sheet> -->
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
