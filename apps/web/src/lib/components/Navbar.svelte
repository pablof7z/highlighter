<script lang="ts">
	import { page } from '$app/stores';
	import Logo from '$icons/Logo.svelte';
	import { currentUser } from '$stores/current-user';
	// import { notificationsEnabled } from '$stores/notifications';
	import { AttentionButton, PrimaryButton } from '@kind0/ui-common';
	import CurrentUser from './CurrentUser.svelte';
	import NotificationButton from './NotificationButton.svelte';
	import { MagicWand, PersonSimpleRun, Rss, Sparkle } from 'phosphor-svelte';
</script>

<div class="navbar mb-2 bg-base-100 px-8">
	<div class="navbar-start">
		<div class="dropdown  ">
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
				<li>
					<a class:tab-active={$page.url.pathname === '/jobs'} class="" href="/jobs"
						>Job Request Feed</a
					>
				</li>
				<li>
					<a class:tab-active={$page.url.pathname === '/dvms'} class="" href="/dvms">List DVMs</a>
				</li>
				{#if $currentUser}
					<li>
						<a class:tab-active={$page.url.pathname === '/jobs/my'} class="" href="/jobs/my"
							>Your Jobs</a
						>
					</li>
				{/if}
				<li>
					<a class:tab-active={$page.url.pathname === '/jobs/new'} class="" href="/jobs/new"
						>Create Job Chain</a
					>
				</li>
			</ul>
		</div>
		<a href="/" class="btn btn-ghost text-xl normal-case px-0 hover:bg-transparent">
			<Logo class="h-12 w-12" />
			<h1 class="text-xl font-bold">VENDATA</h1>
		</a>
	</div>

	<div class="navbar-center hidden flex-row gap-8 xl:flex">
		<ul class="menu menu-horizontal !bg-transparent">
			<li>
				<a class:tab-active={$page.url.pathname === '/magic'} class="" href="/magic">
					<MagicWand class="h-6 w-6" />
					Magic</a
				>
			</li>
		</ul>

		<ul class="menu menu-horizontal !bg-transparent">
			<li>
				<a class:tab-active={$page.url.pathname === '/jobs'} class="" href="/jobs">
					<Rss class="h-6 w-6" />
					Job Request Feed</a
				>
			</li>
			<li>
				<a class:tab-active={$page.url.pathname === '/dvms'} class="" href="/dvms">
					<Sparkle class="h-6 w-6" />
					Data Vending Machines
				</a>
			</li>
			{#if $currentUser}
				<li>
					<a class:tab-active={$page.url.pathname === '/jobs/my'} class="" href="/jobs/my">
						<PersonSimpleRun class="h-6 w-6" />
						Your Jobs
					</a>
				</li>
			{/if}
		</ul>

		<div>
			<PrimaryButton color="accent" href="/jobs/new" class="btn btn-accent btn-outline ml-12 !rounded-full !py-1">
				SUBMIT NEW JOB
			</PrimaryButton>
		</div>
	</div>
	<div class="navbar-end flex flex-row items-center gap-4">
		<!-- {#if $notificationsEnabled}
			<NotificationButton />
		{/if} -->

		<CurrentUser />
	</div>
</div>
