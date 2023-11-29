<script lang="ts">
	import { page } from '$app/stores';
	import Logo from '$icons/Logo.svelte';
	import { AttentionButton, PrimaryButton, user } from '@kind0/ui-common';
	import CurrentUser from './CurrentUser.svelte';
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { openModal } from 'svelte-modals';
	import ExploreIcon from '$icons/ExploreIcon.svelte';
	import { Tray } from 'phosphor-svelte';

	export let maxSize = "max-w-7xl";
</script>

<div class="navbar mb-2 bg-base-100 px-8 mx-auto {maxSize} {$$props.class??""} fixed top-0 z-20 bg-opacity-80 backdrop-blur">
	<div class="navbar-start items-center">
		<div class="dropdown">
			<label tabindex="0" class="btn btn-ghost xl:hidden">
				<svg
					xmlns="http://www.w3.org/2000/svg"
					class="h-5 w-5"
					fill="none"
					viewBox="0 0 24 24"
					stroke="currentColor"
					><path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M4 6h16M4 12h8m-8 6h16"
					/></svg
				>
			</label>
			<ul
				tabindex="0"
				class="menu dropdown-content rounded-box menu-sm z-[1] mt-3 w-52 bg-base-100 p-2 shadow"
			>
			</ul>
		</div>

		<a href="/" class="btn btn-ghost text-xl normal-case px-0 hover:bg-transparent">
			<Logo />
		</a>

		<div class="ml-14 flex flex-row items-center gap-8">
			<a
				href="/explore"
				class="justify-start items-center gap-2 inline-flex"
				class:active={$page.url.pathname === '/explore'}
				>
				<div class="w-6 h-6 relative">
					<ExploreIcon />
				</div>
				<div class="">Explore</div>
			</a>

			<a
				href="/inbox"
				class="justify-start items-center gap-2 inline-flex"
				class:active={$page.url.pathname === '/inbox'}
				>
				<div class="w-6 h-6 relative">
					<Tray class="w-full h-full" />
				</div>
				<div class="">Inbox</div>
			</a>
		</div>
	</div>

	<div class="navbar-center hidden flex-row gap-8 xl:flex">
	</div>
	<div class="navbar-end flex flex-row items-center gap-4">
		{#if $user}
			<button class="button" on:click={() => openModal(NewItemModal)}>
				Publish
			</button>
		{/if}

		<CurrentUser />
	</div>
</div>

<style lang="postcss">
	.navbar a {
		@apply text-[15px] text-opacity-60 leading-5 font-semibold;
	}

	.active {
		@apply !text-white;
	}
</style>