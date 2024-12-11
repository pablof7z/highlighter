<script lang="ts">
	import type { NodeViewProps } from '@tiptap/core';
	import type { NEventAttributes, NAddrAttributes } from 'nostr-editor';
	import cx from 'clsx';
	import { NodeViewWrapper } from 'svelte-tiptap';
	import Name from '@components/user/Name.svelte';
	import type { NDKEvent } from '@nostr-dev-kit/ndk';
    import * as Event from '@components/Event'; 

	export let node: NodeViewProps['node'];
	export let selected: boolean = false;
	export let updateAttributes: NodeViewProps['updateAttributes'];
	// export let deleteNode: NodeViewRendererProps['deleteNode']

	$: attrs = node.attrs as NEventAttributes | NAddrAttributes;

	// console.log('pubkey', node?.attrs);

	// let pubkey: string;

    let bech32: string;

    $: bech32 = attrs.naddr || attrs.nevent;

    $: console.log('bech32', bech32);

	// $: try {
	// 	if (attrs.nprofile) {
	// 		if (attrs.nprofile.match(/:/)) {
	// 			nprofile = attrs.nprofile.split(/:/)[1];
	// 		} else {
	// 			nprofile = attrs.nprofile;
	// 		}
	// 	}
	// } catch {}

    let event: NDKEvent | null;
</script>

<NodeViewWrapper data-type="nevent" as="div">
    <div class="font-sans border-4 border-transparent" class:selected={selected}>
        {#if bech32}
            <Event.Root eventId={bech32} bind:event={event}>
                <Event.Card {event} />
            </Event.Root>
        {:else}
            <pre>{JSON.stringify(attrs, null, 4)}</pre>
        {/if}
    </div>
</NodeViewWrapper>

<style lang="postcss">
    .selected {
        @apply border-4 border-primary rounded-lg;
    }
</style>