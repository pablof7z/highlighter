<script lang="ts">
	import { appMobileView } from "$stores/app";
	import { modals, modalState } from "$stores/layout";
	import { closeModal } from "$utils/modal";
	import { Modals, openModal, closeModal as closeModalReal } from "svelte-modals";
	import * as Drawer from "$lib/components/ui/drawer";
</script>

	{#each $modals as modal}
					<svelte:component this={modal.component} {...modal.props} />
	{/each}
	<!-- <Sheet
		class="pb-safe w-full max-h-[calc(100vh-44px)]"
		onBackdropClick={closeModal}
	>
		{#if $modal}
			
		{/if}
	</Sheet> -->