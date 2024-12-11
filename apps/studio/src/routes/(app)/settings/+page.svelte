<script lang="ts">
	import MediaServers from "@/components/Settings/MediaServers.svelte";
	import Relays from "@/components/Settings/Relays.svelte";
	import Sidebar from "@/components/Settings/Sidebar.svelte";
    import { Separator } from "@/components/ui/separator";

    let selectedSetting = $state('Relays');
</script>

<div class="hidden space-y-6 pb-16 md:block">
	<div class="max-w-4xl mx-auto py-6">
		<h2 class="text-4xl font-medium tracking-tight">Settings</h2>
		<p class="text-muted-foreground">
			Manage your account settings and set e-mail preferences.
		</p>
	</div>

	<Separator class="my-6" />

	<div class="max-w-4xl mx-auto">
		<div class="flex flex-col space-y-8 lg:flex-row lg:space-x-12 lg:space-y-0">
			<aside class="-mx-4 lg:w-1/5">
				<Sidebar bind:selectedSetting />
			</aside>
			<div class="flex-1 lg:max-w-2xl">
				{#if selectedSetting === 'Media Servers'}
					<MediaServers />
				{:else if selectedSetting === 'Relays'}
					<Relays />
				{/if}
			</div>
		</div>
	</div>
</div>