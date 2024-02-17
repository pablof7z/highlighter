<script lang="ts">
    import { pageSidebar, pageHeader, sidebarPlacement } from "$stores/layout";
	import { loginState } from '$stores/session';
	import { Toaster, pageDrawerToggle, rightSidebar, user } from '@kind0/ui-common';
    import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import Navigation from "./Navigation.svelte";
	import SectionHeader from "./SectionHeader.svelte";
	import { page } from "$app/stores";
	import SectionHeaderWithButtons from "./SectionHeaderWithButtons.svelte";

    let hasSidebar = false;
	let showSectionHeaderWithButtons = false;

	$: hasSidebar = !!$pageSidebar?.component;

	let pageId: string | null;

	$: {
		pageId = $page.route.id;

		// if route is /[id]/[tagId]/ and either comments, highlights, collections set showSectionHeaderWithButtons to true
		if (pageId && pageId.startsWith("/[id]/[tagId]/") && (pageId.endsWith("/comments") || pageId.endsWith("/highlights") || pageId.endsWith("/collections"))) {
			showSectionHeaderWithButtons = true;
		} else {
			showSectionHeaderWithButtons = false;
		}
	}

	let checked: boolean;

	$: checked = $pageDrawerToggle;
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

			<div class="sm:pl-20">
				{#if $pageSidebar?.component}
					<div class="fixed border-r border-base-300 flex-col h-full w-96 max-lg:w-full max-lg:hidden">
						<svelte:component this={$pageSidebar.component} {...$pageSidebar.props} />
					</div>
				{/if}
				<div
					class:lg:pl-96={hasSidebar}
				>
					{#if $pageHeader?.title || $pageHeader?.component}
						<div class="max-sm:hidden">
							<SectionHeader />
						</div>
					{/if}
					{#if $pageHeader?.title && $pageHeader?.component}
						{#if showSectionHeaderWithButtons}
							<div class="max-sm:hidden w-full">
								<SectionHeaderWithButtons title={$pageHeader.title} />
							</div>
						{:else}
							<div class="max-sm:hidden w-full flex flex-col items-stretch justify-stretch">
								<SectionHeader title={$pageHeader.title} {hasSidebar} />
							</div>
						{/if}
					{/if}

					<slot />
				</div>
			</div>
		{/key}
	</div>
	<div
		class="drawer-side z-50"
	>
		<label for="my-drawer-4" aria-label="close sidebar" class="drawer-overlay"></label>
		<div
			class="menu w-[80vw] sm:w-[40vw] sm:max-w-[25rem] min-h-full bg-base-200 text-base-content p-4"
			class:max-sm:mt-16={$sidebarPlacement === "left"}
			on:click={() => $pageDrawerToggle = false}
		>
			<svelte:component this={$rightSidebar.component} {...$rightSidebar.props} />
		</div>
	</div>
</div>
