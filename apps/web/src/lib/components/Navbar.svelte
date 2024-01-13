<script lang="ts">
	import { page } from '$app/stores';
	import Logo from '$icons/Logo.svelte';
	import { user } from '@kind0/ui-common';
	import CurrentUser from './CurrentUser.svelte';
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { openModal } from 'svelte-modals';
	import { Compass, Tray, ChatCircle, Receipt, PencilSimple, PencilSimpleLine, PlusCircle } from 'phosphor-svelte';

	export let maxSize = "max-w-7xl";
</script>

<div class="navbar mb-2 bg-base-100 sm:px-8 mx-auto {maxSize} {$$props.class??""} fixed top-0 z-20 bg-opacity-80 backdrop-blur-[50px]">
	<div class="navbar-start items-center">
		<a href="/" class="btn btn-ghost text-xl normal-case px-0 hover:bg-transparent">
			<Logo class="h-12" />
		</a>

		<div class="ml-8 sm:ml-14 flex flex-row items-center gap-8 links whitespace-nowrap">
			<a
				href="/explore"
				class="justify-start items-center gap-2 inline-flex"
				class:active={$page.url.pathname.startsWith('/explore')}
				>
				<div class="w-6 h-6 relative">
					<Compass class="w-full h-full" />
				</div>
				<span class="">Explore</span>
			</a>

			<a
				href="/inbox"
				class="justify-start items-center gap-2 inline-flex"
				class:active={$page.url.pathname === '/inbox'}
				>
				<div class="w-6 h-6 relative">
					<Tray class="w-full h-full" />
				</div>
				<span class="">Inbox</span>
			</a>

			<a
				href="/chat"
				class="justify-start items-center gap-2 inline-flex hidden"
				class:active={$page.url.pathname === '/chat'}
				>
				<div class="w-6 h-6 relative">
					<ChatCircle class="w-full h-full" />
				</div>
				<span class="">Chat</span>
			</a>

			<a
				href="/clips"
				class="justify-start items-center gap-2 inline-flex"
				class:active={$page.url.pathname === '/clips'}
				>
				<div class="w-6 h-6 relative">
					<PencilSimpleLine class="w-full h-full" />
				</div>
				<span class="">Highlights</span>
			</a>
		</div>
	</div>

	<div class="navbar-center hidden flex-row gap-8 xl:flex">
	</div>
	<div class="navbar-end flex flex-row items-stretch gap-4">
		{#if $user}
			<button class="button button-black max-md:hidden px-6" on:click={() => openModal(NewItemModal)}>
				<PlusCircle class="w-6 h-6" />
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

	.links a span {
		@apply max-sm:hidden;
	}
</style>