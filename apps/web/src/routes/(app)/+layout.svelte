<script lang="ts">
	import MobileBottomNavbar from '$components/MobileBottomNavbar.svelte';
	import Navbar from '$components/Navbar.svelte';
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
			Drawer
		</div>
	</div>
</div>

<MobileBottomNavbar />