<script lang="ts">
	import { layoutMode, pageSidebar } from '$stores/layout.js';
    import { layoutNavState, detailView } from "$stores/layout";
	import { Toaster, pageDrawerToggle } from '@kind0/ui-common';
	import Modal from './Modal.svelte';
	import { page } from "$app/stores";
	import LayoutNavigation from "./AppShell/LayoutNavigation.svelte";
	import PageNavigation from "./AppShell/PageNavigation.svelte";
	import LayoutDetailView from "./AppShell/LayoutDetailView.svelte";
	import LayoutHeader from './AppShell/LayoutHeader.svelte';
	import PageSidebar from './AppShell/PageSidebar.svelte';

	let showSectionHeaderWithButtons = false;

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

	let layoutWrapper: string;
	let navWrapper: string;
	let mainAndDetailWrapper: string;
	let mainWrapper: string;
	let detailWrapper: string;
	let sidebarWrapper: string;

	/**
	 * This tracks the known value of layout-mode so we can react to changes in
	 * opening a detail-view, so that we can collapse the navbar and uncollapse it
	 * when the detail view is closed
	 */
	let prevLayoutMode: string;
	let originalNavState: string;
	
	$: {
		if (prevLayoutMode !== $layoutMode) {
			prevLayoutMode = $layoutMode;
			originalNavState = $layoutNavState;
		} else if (originalNavState === "normal") {
			// These are the conditions in which we might need to change the layout nav state to collapse it
			if ($detailView) {
				$layoutNavState = "collapsed";
			} else {
				$layoutNavState = "normal";
			}
		}
	}

	$: switch ($layoutMode) {
		case 'full-width':
			$layoutNavState = "collapsed";
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "max-w-none w-full";
			mainWrapper = "w-full";
			if ($pageSidebar) {
				sidebarWrapper = "w-1/3 max-w-[400px] lg:p-6";
				mainAndDetailWrapper = "max-w-none w-[calc(100vw_-_400px)]";
				mainWrapper = "w-[calc(100vw_-_400px)]";
			}
			navWrapper = "sm:left-0 sticky";
			
			break;
		case 'centered-feed-column':
			mainAndDetailWrapper = "";
			navWrapper = "sticky";
			detailWrapper = "";

			if ($detailView) {
				mainAndDetailWrapper = "w-full";
				mainWrapper = "w-1/2";
				detailWrapper = "w-1/2";
				layoutWrapper = "w-full mx-auto";
			} else {
				mainAndDetailWrapper = "max-w-5xl w-full";
				mainWrapper = "max-w-3xl w-screen";
				layoutWrapper = "max-w-7xl mx-auto";
			}

			break;
		case 'content-focused':
			$layoutNavState = 'collapsed';
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "max-w-7xl mx-auto w-fit justify-center";
			navWrapper = "fixed sm:left-0 bg-base-200";
			mainWrapper = "max-w-3xl w-full grow";

			if ($pageSidebar) {
				sidebarWrapper = "w-1/3 max-w-[500px] lg:px-6 top-0";
				mainAndDetailWrapper = "max-w-7xl mr-auto w-fit justify-center";
			}
			
			break;
		// case "list-column":
		// 	$layoutNavState = 'collapsed';
		// 	layoutWrapper = "w-full";
		// 	mainAndDetailWrapper = "flex-row-reverse w-[calc(100vw_-_5rem)]";
		// 	navWrapper = "sticky sm:left-0 !bg-base-200 sm:h-screen";
		// 	mainWrapper = "w-2/3 grow lg:px-6";
		// 	detailWrapper = "w-1/3 max-w-[500px] lg:p-6";
		// 	break;
		case "single-column-focused":
			$layoutNavState = 'collapsed';
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "max-w-5xl mx-auto w-fit justify-center";
			navWrapper = "fixed sm:left-0 bg-base-200";
			mainWrapper = "max-w-3xl w-full grow";
			break;
	}
</script>

<Modal />

<Toaster />

<div class="
	_border border-red-500
	flex flex-col min-h-screen items-stretch justify-stretch
	gap-0 h-ful
	max-w-screen overflow-x-clip
">
	<div class="
		flex flex-row items-stretch justify-center h-full _border border-yellow-500
		{layoutWrapper}
	">
		<!-- Layout navbar -->
		<LayoutNavigation class={navWrapper} />

		<PageSidebar class={sidebarWrapper} />

		<div class="
			flex flex-row w-full _border border-green-500
			min-h-screen
			{mainAndDetailWrapper}
		">
			<main class="
				!border-x !border-base-300
				flex-none
				shrink
				{mainWrapper}
				">
				<LayoutHeader class={mainWrapper} />
				<PageNavigation />
				<slot />
			</main>

			<LayoutDetailView class={detailWrapper} />
		</div>
	</div>
</div>

<style lang="postcss">
	:global(.toast) {
		@apply fixed bottom-2 right-2;
	}
</style>

<div class="hidden max-w-xl"></div>