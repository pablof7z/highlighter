<script lang="ts">
	import { modal, modalState } from "$stores/layout";
    import Device from "svelte-device-info";
	import { Modals, closeModal, openModal } from "svelte-modals";
	import { fade } from "svelte/transition";
	import { Drawer } from "vaul-svelte";
    
    let isPhone = Device.isPhone;
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
	<Drawer.Root open={!!$modal}>
		<Drawer.Portal>
			<Drawer.Overlay class="fixed inset-0 bg-black/50 z-50" />
			<Drawer.Content
				class="bg-base-100 flex flex-col rounded-t-box mt-24 z-[999999] fixed bottom-0 left-0 right-0"
			>
				<div class="rounded-t-box flex-1">
					<div class="mx-auto w-12 h-1.5 flex-shrink-0 rounded-full mt-4 bg-white" />
				</div>
				
				{#if $modal}
					<svelte:component this={$modal.component} {...$modal.props} />
				{/if}
			</Drawer.Content>
		</Drawer.Portal>
	</Drawer.Root>
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