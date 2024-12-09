<script lang="ts">
	import DraftButton from '@/components/buttons/Draft/DraftButton.svelte';
	import Button from '@/components/ui/button/button.svelte';
	import { ArrowLeft } from 'svelte-radix';

	let { onContinue, editorState = $bindable() } = $props();
</script>

<div class="flex w-full items-center justify-between">
	<div class="flex flex-row items-center gap-2">
		<Button variant="secondary" size="icon" href="/">
			<ArrowLeft size="18" weight="bold" />
		</Button>

		<DraftButton bind:editorState />
	</div>

	<Button variant="default" onclick={onContinue}>Continue</Button>
</div>
