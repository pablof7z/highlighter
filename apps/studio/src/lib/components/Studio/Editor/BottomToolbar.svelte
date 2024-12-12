<script lang="ts">
	import ToggleDark from '@/components/buttons/ToggleDark.svelte';
	import { Button } from '@/components/ui/button';
	import { History } from 'lucide-svelte';
	import type { EditorState } from '../state.svelte';

	export type Props = {
		editorState: EditorState;
		onOpenSettings: () => void;
		onOpenHistory: () => void;
	}
	
	let { editorState, onOpenSettings, onOpenHistory }: Props = $props();
</script>

<div class="flex flex-row gap-2">
	{#if editorState.draft}
		<Button variant="secondary" size="icon" onclick={onOpenHistory}>
			<History />
		</Button>
	{/if}
	<ToggleDark />
</div>

<Button variant="secondary" onclick={onOpenSettings}>Settings</Button>
