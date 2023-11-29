<script lang="ts">
	import Navbar from '$components/Navbar.svelte';
</script>

<div class="flex items-center justify-center h-[68px] mb-2">
	<Navbar />
</div>

<div class="mx-auto max-w-7xl">
	<slot />
</div>