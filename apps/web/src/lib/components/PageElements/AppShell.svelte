<script lang="ts">
	import { layoutMode, pageHeader, pageSidebar } from '$stores/layout.js';
	import { Toaster, pageDrawerToggle } from '@kind0/ui-common';
	import Modal from './Modal.svelte';
	import LayoutNavigation from "./AppShell/LayoutNavigation.svelte";
	import PageNavigation from "./AppShell/PageNavigation.svelte";
	import LayoutHeader from './AppShell/LayoutHeader.svelte';
	import PageSidebar from './AppShell/PageSidebar.svelte';

	let checked: boolean;

	$: checked = $pageDrawerToggle;

	let layoutWrapper: string;
	let mainAndDetailWrapper: string;
	let mainWrapper: string;
	let detailWrapper: string;
	let sidebarWrapper: string;

	$: switch ($layoutMode) {
		case 'full-width':
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "max-w-none w-full";
			mainWrapper = "w-full";
			if ($pageSidebar) {
				sidebarWrapper = "w-1/3 max-w-[500px]";
				mainAndDetailWrapper = "max-w-none w-[calc(100vw_-_500px)]";
				mainWrapper = "w-[calc(100vw_-_500px)]";
			}
			
			break;
		case 'content-focused':
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "max-w-[var(--content-focused-wrapper-width)] mx-auto w-full justify-center";
			mainWrapper = "max-w-[var(--content-focused-width)] w-full grow";

			if ($pageSidebar) {
				sidebarWrapper = "w-1/3 max-w-[500px] top-0";
				mainAndDetailWrapper = "max-w-7xl mr-auto w-fit justify-center";
			}
			
			break;
		// case "list-column":
		// 	layoutWrapper = "w-full";
		// 	mainAndDetailWrapper = "flex-row-reverse w-[calc(100vw_-_5rem)]";
		// 	mainWrapper = "w-2/3 grow lg:px-6";
		// 	detailWrapper = "w-1/3 max-w-[500px] lg:p-6";
		// 	break;
		case "single-column-focused":
			mainAndDetailWrapper = "";
			detailWrapper = "";

			mainAndDetailWrapper = "max-w-5xl mx-auto w-full";
			mainWrapper = "max-w-3xl mx-auto w-screen";
			layoutWrapper = "max-w-7xl mx-auto";
			break;
	}
</script>

<Modal />

<Toaster />

<!-- Layout navbar -->
<LayoutNavigation />

<div class="
	min-h-screen items-stretch justify-stretch
	gap-0
	flex flex-col
	w-screen overflow-clip
	ml-[var(--navbar-collapsed)]
">
	<!-- <PageSidebar class={sidebarWrapper} /> -->

	<LayoutHeader containerClass={mainWrapper} />

	<div class="mb-[calc(var(--navbar-height))] w-full"></div>

	<main class="
		flex-none
		{mainWrapper}
	">
		<!-- <PageNavigation /> -->
		<slot />
	</main>
		<!-- <LayoutDetailView class={detailWrapper} /> -->

	{#if $pageHeader && $pageHeader.footer}
		<div class="h-[8rem]"></div>
		<div class="
			fixed bottom-0 w-full border-t border-base-300 bg-base-100
			z-[50]
			flex items-center
		">
			<div class="{mainWrapper} p-4">
				<svelte:component this={$pageHeader.footer.component} {...$pageHeader.footer.props} />
			</div>
		</div>
	{/if}
</div>

<style lang="postcss">
	:global(.toast) {
		@apply fixed bottom-2 right-2;
	}
</style>

<div class="hidden max-w-xl"></div>