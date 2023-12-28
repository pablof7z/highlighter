<script lang="ts">
	import MobileBottomNavbar from '$components/MobileBottomNavbar.svelte';
	import Navbar from '$components/Navbar.svelte';
	import { debugMode, userActiveSubscriptions, userFollows } from '$stores/session';
	import { logout } from '$utils/login';
	import { user } from '@kind0/ui-common';
	import { Bug } from 'phosphor-svelte';
</script>

<div class="flex items-center justify-center max-sm:hidden h-[68px] mb-2">
	<Navbar />
</div>

<div class="drawer drawer-end">
	<input id="mobile-drawer" type="checkbox" class="drawer-toggle" />
	<div class="drawer-content h-full">
		<div class="mx-auto max-w-7xl">
			<slot />
		</div>
	</div>
	<div class="drawer-side z-50">
		<label for="mobile-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
		<div class="menu w-[40vw] min-h-full bg-base-200 text-base-content p-8">


			<button on:click={logout} class="button w-full">Log Out</button>

			{#if $debugMode}
				<div class="self-end">
					<div class="flex flex-col gap-4 items-start text-sm">
                        <div>Debug Information</div>
                        <p>User follows: {$userFollows.size}</p>
                        <p>User super-follows: {$userFollows.size}</p>
                        <p>Active Subscriptions: {$userActiveSubscriptions.size}</p>
                    </div>
				</div>
			{/if}

			{#if import.meta.env.VITE_HOSTNAME === "localhost" || $user?.npub === "npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft"}
				<button
					on:click={() => $debugMode = !$debugMode}
					class="right-2 z-50 btn btn-circle btn-sm">
					<Bug size="24" />
				</button>
			{/if}
		</div>
	</div>
</div>

<div class="flex items-center justify-center sm:hidden h-[68px] mb-2">
	<MobileBottomNavbar />
</div>