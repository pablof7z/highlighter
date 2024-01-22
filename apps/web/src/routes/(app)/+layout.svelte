<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import HighlightIcon from './../../lib/icons/HighlightIcon.svelte';
	import { page } from '$app/stores';
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { openModal } from 'svelte-modals';
	import MobileBottomNavbar from '$components/MobileBottomNavbar.svelte';
	import LogoSmall from '$icons/LogoSmall.svelte';
	import CurrentUser from '$components/CurrentUser.svelte';
	import Navbar from '$components/Navbar.svelte';
	import { PaperPlaneTilt } from 'phosphor-svelte';
	import { Compass, Tray, ChatCircle } from 'phosphor-svelte';
	import { debugMode, userActiveSubscriptions, userFollows } from '$stores/session';
	import { logout } from '$utils/login';
	import { user } from '@kind0/ui-common';
	import { Bug } from 'phosphor-svelte';
	import { userTiers } from '$stores/session';
	import VerticalNavbar from '$components/VerticalNavbar.svelte';
	import { pageSidebar } from "$stores/layout";

	let hasSidebar = false;

	$: hasSidebar = !!$pageSidebar?.component;

	// openModal(SignupModal)
</script>

<div>
	<VerticalNavbar />

	<div class="md:pl-20">
		{#if $pageSidebar?.component}
			<div class="fixed border-r border-base-300 flex-col h-full w-96 max-xl:hidden">
				<svelte:component this={$pageSidebar.component} {...$pageSidebar.props} />
			</div>
		{/if}

		<div
			class:xl:pl-96={hasSidebar}
		>
			<slot />
		</div>
	</div>

</div>

<style lang="postcss">
	.navbar a {
		@apply text-[15px] text-opacity-60 leading-5 font-semibold;
	}

	.active {
		@apply !text-accent2;
	}

	.links a span {
		@apply max-lg:hidden;
	}
</style>