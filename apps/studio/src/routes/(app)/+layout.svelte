<script lang="ts">
	import '@fontsource/spectral';
	import '@fontsource/spectral/300.css';
	import '@fontsource/spectral/300-italic.css';
	import '@fontsource/spectral/500.css';
	import '@fontsource/spectral/500-italic.css';
	import '@fontsource/spectral/600.css';
	import '@fontsource/spectral/600-italic.css';

	import { currentUser } from '@/state/current-user.svelte';
	import Signup from '@components/auth/signup.svelte';
	import AccountSwitcher from '@components/layout/AccountSwitcher.svelte';
	import CurrentUser from '@components/layout/CurrentUser.svelte';
	import DashboardLight from '@/img/dashboard-light.png?enhanced';
	import DashboardDark from '@/img/dashboard-dark.png?enhanced';
	import MainNav from '@/dashboard/main-nav.svelte';
	import Logo from '@/components/Logo.svelte';
	import NewPost from '@/components/buttons/new-post.svelte';
	import { Plus, PlusCircle } from 'lucide-svelte';
	
	let { children } = $props();
</script>

{#if currentUser() !== null}
	<div class="md:hidden">
		<enhanced:img src={DashboardLight} alt="Dashboard" class="block dark:hidden" />
		<enhanced:img src={DashboardDark} alt="Dashboard" class="hidden dark:block" />
	</div>
	<div class="flex flex-col">
		<div class="border-b">
			<div class="flex h-16 items-center px-4">
				<a href="/" class="mr-4">
					<Logo />
				</a>
				
				<AccountSwitcher />

				<MainNav />
				
				<div class="ml-auto flex items-center space-x-4">
					<!-- <Search /> -->
					 <NewPost variant="outline" class="rounded-full">
						<Plus class="h-4 w-4" />
					</NewPost>
					<CurrentUser />
				</div>
			</div>
		</div>

		<div class="flex-1 space-y-4 p-2 md:p-8 md:pt-6">
			{@render children()}
		</div>
	</div>
{:else}
	<Signup />
{/if}
