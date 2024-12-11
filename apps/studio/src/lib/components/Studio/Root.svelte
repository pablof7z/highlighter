<script lang="ts">
	import { ndk } from '@/state/ndk';
	import Editor from './Editor/index.svelte';
	import { EditorState } from './state.svelte';

	/**
	 * This component loads the event, if an event id has been provided,
	 */
	const { type, id } = $props();

	let editorState = $state<EditorState | null>(null);

	if (id === 'new') {
		if (type === 'article') {
			editorState = new EditorState();
			editorState.relays = ndk.pool.connectedRelays().map((r) => r.url);
		}
	} else {
		ndk.fetchEvent(id).then((e) => {
			if (e) {
				console.log('loaded', JSON.stringify(e.rawEvent()));
				EditorState.from(e).then((state) => (editorState = state));
			}
		});
	}
</script>

{#if editorState}
	<Editor bind:editorState />
{/if}
