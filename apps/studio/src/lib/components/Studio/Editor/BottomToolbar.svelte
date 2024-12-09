<script lang="ts">
	import ToggleDark from '@/components/buttons/ToggleDark.svelte';
	import { Button } from '@/components/ui/button';

	let { onOpenSettings } = $props();
</script>

<ToggleDark />

<Button variant="secondary" onclick={onOpenSettings}>Settings</Button>
