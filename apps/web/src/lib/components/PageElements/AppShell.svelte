<script lang="ts">
	import { layoutMode, pageHeader } from '$stores/layout.js';
	import Modal from './Modal.svelte';
	import LayoutNavigation from "./AppShell/LayoutNavigation.svelte";
	import LayoutHeader from './AppShell/LayoutHeader.svelte';
	import Toaster from './Toaster.svelte';

	let layoutWrapper: string;
	let mainWrapper: string;

	$: switch ($layoutMode) {
		case 'full-width':
			layoutWrapper = "w-full";
			mainWrapper = "";
			break;
		case 'content-focused':
			layoutWrapper = "w-full";
			mainWrapper = "max-w-[var(--content-focused-width)] w-full grow";
			break;
		case "single-column-focused":
			mainWrapper = "max-w-3xl mx-auto w-full";
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
	overflow-clip
	pl-[var(--navbar-width)]
">
	<LayoutHeader containerClass="sm:-translate-x-[calc(var(--navbar-width)/2)] {mainWrapper}" />

	<div class="mb-[calc(var(--navbar-height))] w-full"></div>

	<main class="
		flex-none
		{mainWrapper}
	">
		<slot />
	</main>

	{#if $pageHeader && $pageHeader.footer}
		<div class="h-[8rem]"></div>
		<div class="
			fixed bottom-0 w-full border-t border-border bg-background
			z-[50]
			flex items-center
		">
			<div class="sm:-translate-x-[calc(var(--navbar-width)/2)] {mainWrapper}">
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