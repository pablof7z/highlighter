<script lang="ts">
	import { appMobileView } from "$stores/app";
	import { modal, modalState } from "$stores/layout";
	import { closeModal } from "$utils/modal";
	import { Block, Sheet } from "konsta/svelte";
	import { Modals, openModal, closeModal as closeModalReal } from "svelte-modals";
	import { fade } from "svelte/transition";
</script>

{#if $appMobileView}
	<Sheet
		class="pb-safe w-full max-h-[calc(100vh-44px)]"
		opened={!!$modal}
		onBackdropClick={closeModal}
	>
		{#if $modal}
			<svelte:component this={$modal.component} {...$modal.props} />
		{/if}
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
