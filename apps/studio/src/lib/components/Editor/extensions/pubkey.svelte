<script lang="ts">
	import type { NodeViewProps } from '@tiptap/core';
	import type { NEventAttributes } from 'nostr-editor';
	import cx from 'clsx';
	import { NodeViewWrapper } from 'svelte-tiptap';
	import Name from '@components/user/Name.svelte';

	export let node: NodeViewProps['node'];
	export let selected: boolean = false;
	export let updateAttributes: NodeViewProps['updateAttributes'];
	// export let deleteNode: NodeViewRendererProps['deleteNode']

	$: attrs = node.attrs as NEventAttributes;

	// console.log('pubkey', node?.attrs);

	// let pubkey: string;
	let nprofile: string;

	$: try {
		if (attrs.nprofile) {
			if (attrs.nprofile.match(/:/)) {
				nprofile = attrs.nprofile.split(/:/)[1];
			} else {
				nprofile = attrs.nprofile;
			}
		}
	} catch {}
</script>

<NodeViewWrapper data-type="nprofile" as="span">
	{#if nprofile}
		<button class="mention {selected ? 'bg-secondary border-primary border-b' : ''}">
			<Name of={nprofile} class="mention text-foreground" />
		</button>
	{:else}
		Pubkey
		{attrs}
		<pre>{JSON.stringify(attrs, null, 4)}</pre>
	{/if}
</NodeViewWrapper>
