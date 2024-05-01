<script lang="ts">
	import { contentCentricLayout, layoutMode } from '$stores/layout.js';
    import { pageSidebar, pageHeader, sidebarPlacement, modalState, layoutMaxWidth, layoutAlign, layoutNavState, pageMainContentMaxWidth, mainAlign, detailView } from "$stores/layout";
	import { Toaster, pageDrawerToggle, rightSidebar, user } from '@kind0/ui-common';
    import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import { page } from "$app/stores";
	import LayoutNavigation from "./AppShell/LayoutNavigation.svelte";
	import PageNavigation from "./AppShell/PageNavigation.svelte";
	import LayoutDetailView from "./AppShell/LayoutDetailView.svelte";
	import LayoutHeader from './AppShell/LayoutHeader.svelte';

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

	/**
	 * The max width of the layout is either explicit or calculated
	 * based on the size of the navbar and the presence of a sidebar
	 */
	let layoutEffectiveMaxWidth: string;
	$: if ($layoutMaxWidth) {
		layoutEffectiveMaxWidth = $layoutMaxWidth;
	} else {
		if (!$detailView) {
			if ($pageMainContentMaxWidth) {
				layoutEffectiveMaxWidth = $pageMainContentMaxWidth;
			} else if ($layoutNavState === "collapsed") {
				layoutEffectiveMaxWidth = "max-w-7xl";
			} else {
				layoutEffectiveMaxWidth = "max-w-7xl";
			}
		} else {
			layoutEffectiveMaxWidth = "max-w-none";
		}
	}

	let layoutWrapper: string;
	let navWrapper: string;
	let mainAndDetailWrapper: string;
	let mainWrapper: string;
	let detailWrapper: string;

	$: switch ($layoutMode) {
		case 'full-width':
			$layoutNavState = 'collapsed';
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "max-w-none w-full";
			navWrapper = "sm:left-0 sticky";
			mainWrapper = "w-full";
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
			navWrapper = "fixed sm:left-0";
			mainWrapper = "max-w-3xl w-full grow";
			break;
		case "reversed-columns":
			layoutWrapper = "w-full";
			mainAndDetailWrapper = "flex-row-reverse w-[calc(100vw_-_5rem)]";
			navWrapper = "sticky sm:left-0";
			mainWrapper = "w-2/3";
			detailWrapper = "w-1/3";
			break;
	}
</script>

<Modals>
	<div
		slot="backdrop"
		class="backdrop z-[51] fixed"
		class:hidden={$modalState !== "open"}
		on:click={closeModal}
		transition:fade={{ duration: 300 }}></div>
</Modals>

<Toaster />

<div class="
	_border border-red-500
	flex flex-col min-h-screen items-stretch justify-stretch
	gap-0 h-full

	max-w-screen overflow-x-clip
">
	<LayoutHeader class={mainAndDetailWrapper} />

	<div class="
		flex flex-row items-stretch justify-center h-full _border border-yellow-500
		{layoutWrapper}
	">
		<!-- Layout navbar -->
		<LayoutNavigation class={navWrapper} />

		<div class="
			flex flex-row w-full _border border-green-500
			{mainAndDetailWrapper}
		">
			<main class="
				!border-x !border-base-300
				flex-none
				shrink
				{mainWrapper}
			">
				<PageNavigation />
				<!-- <p>layoutMode = {$layoutMode}</p>
				<p>mainWrapper = {mainWrapper}</p>
				<p>mainAndDetailWrapper = {mainAndDetailWrapper}</p> -->

				<slot />
			</main>

			<LayoutDetailView class={detailWrapper} />
		</div>
	</div>
</div>

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

<div class="hidden max-w-xl"></div>