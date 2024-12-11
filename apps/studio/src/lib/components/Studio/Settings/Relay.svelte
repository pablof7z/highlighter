<script lang="ts">
	import RelayList from '@/components/ui/RelayList.svelte';
	import * as Alert from '@components/ui/alert';
	import { EditorState } from '../state.svelte';
	import { Button } from '@/components/ui/button';
	import { DEFAULT_RELAYS } from '@/const';

	let { editorState = $bindable() } = $props() as {
		editorState: EditorState;
	};

	function setDefault() {
		editorState.relays = [...DEFAULT_RELAYS];
	}
</script>

{#if editorState.relays.length === 0}
	<Alert.Root>
		<Alert.Title>No relays</Alert.Title>
		<Alert.Description>
			Nostr content is published to relays; you need to add at least one relay to publish your
			content.

			<div class="mt-4 flex justify-end">
				<Button variant="secondary" onclick={setDefault}>
					Add default relays
				</Button>

			</div>
		</Alert.Description>
	</Alert.Root>
{/if}

<RelayList bind:relays={editorState.relays} />
