<script lang="ts">
	import RelayList from '@/components/ui/RelayList.svelte';
	import * as Alert from '@components/ui/alert';
	import { Button } from '@/components/ui/button';
	import { DEFAULT_RELAYS } from '@/const';
	import type { PostState } from '../../state/index.svelte';

	type Props = {
		postState: PostState;
	};

	let { postState = $bindable() }: Props = $props();

	function setDefault() {
		postState.relays = [...DEFAULT_RELAYS];
	}
</script>

{#if postState.relays.length === 0}
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

<RelayList bind:relays={postState.relays} />