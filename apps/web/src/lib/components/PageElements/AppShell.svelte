<script lang="ts">
    import { pageSidebar, pageHeader, sidebarPlacement } from "$stores/layout";
	import { debugMode, loginState } from '$stores/session';
	import { Toaster, pageDrawerToggle, rightSidebar, user } from '@kind0/ui-common';
	import { Bug } from 'phosphor-svelte';
    import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import Navigation from "./Navigation.svelte";
	import SectionHeader from "./SectionHeader.svelte";

    let hasSidebar = false;

	$: hasSidebar = !!$pageSidebar?.component;
</script>

<Modals>
	<div
		slot="backdrop"
		class="backdrop z-20 fixed"
		on:click={closeModal}
		transition:fade={{ duration: 300 }}></div>
</Modals>

<Toaster />

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

	:global(.toast) {
		@apply fixed bottom-2 right-2;
	}
</style>

<div
	class="drawer"
	class:drawer-end={$sidebarPlacement === "right"}
>
	<input id="my-drawer-4" type="checkbox" class="drawer-toggle" bind:checked={$pageDrawerToggle} />
	<div class="drawer-content">
		{#key $loginState}
			<Navigation />

			<div class="md:pl-20">
				{#if $pageSidebar?.component}
					<div class="fixed border-r border-base-300 flex-col h-full w-96 max-sm:w-full max-sm:hidden">
						<svelte:component this={$pageSidebar.component} {...$pageSidebar.props} />
					</div>
				{/if}

				<div
					class:md:pl-96={hasSidebar}
				>
					{#if $pageHeader?.title}
						<div class="max-sm:hidden">
							<SectionHeader title={$pageHeader.title} />
						</div>
					{/if}

					<slot />
				</div>
			</div>
		{/key}
	</div>
	<div class="drawer-side z-50">
		<label for="my-drawer-4" aria-label="close sidebar" class="drawer-overlay"></label>
		<div class="menu w-[80vw] sm:w-[40vw] min-h-full bg-base-200 text-base-content p-4">
			<svelte:component this={$rightSidebar.component} {...$rightSidebar.props} />
		</div>
	</div>
</div>


{#if import.meta.env.VITE_HOSTNAME === "localhost" || $user?.npub === "npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft"}
	<button
		on:click={() => $debugMode = !$debugMode}
		class="max-sm:hidden fixed bottom-2 right-2 z-50 btn btn-circle btn-sm">
		<Bug size="24" class={$debugMode ? "text-accent2" : "text-neutral-500"} />
	</button>
{/if}