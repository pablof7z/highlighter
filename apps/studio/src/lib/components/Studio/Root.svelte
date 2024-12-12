<script lang="ts">
	import { ndk } from '@/state/ndk';
	import Editor from './Editor/index.svelte';
	import { EditorState } from './state.svelte';
	import { toast } from 'svelte-sonner';

	/**
	 * This component loads the event, if an event id has been provided,
	 */
	const { type, id } = $props();

	let editorState = $state<EditorState | null>(null);

	if (id === 'new') {
		if (type === 'article') {
			editorState = new EditorState();
			editorState.relays = ndk.pool.connectedRelays().map((r) => r.url);
		} else if (type === 'thread') {
			editorState = new EditorState();
			editorState.relays = ndk.pool.connectedRelays().map((r) => r.url);
			editorState.type = 'thread';
		}
	} else {
		ndk.fetchEvent(id).then((e) => {
			if (e) {
				EditorState.from(e).then((state) => (editorState = state));
			}
		})
		.catch((e) => {
			toast.error('error fetching event', e);
		});
	}
</script>

{#if editorState}
	<Editor bind:editorState />
{/if}
