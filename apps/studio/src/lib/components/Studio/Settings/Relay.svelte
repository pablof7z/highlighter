<script lang="ts">
	import RelayList from '@/components/ui/RelayList.svelte';
	import * as Alert from '@components/ui/alert';
	import { EditorState } from '../state.svelte';

	let { editorState = $bindable() } = $props() as {
		editorState: EditorState;
	};
</script>

{#if editorState.relays.length === 0}
	<Alert.Root>
		<Alert.Title>No relays</Alert.Title>
		<Alert.Description>
			Nostr content is published to relays; you need to add at least one relay to publish your
			content.
		</Alert.Description>
	</Alert.Root>
{/if}

<RelayList bind:relays={editorState.relays} />
