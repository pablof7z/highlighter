<script lang="ts">
    import type { NodeViewProps } from '@tiptap/core';
    import type { NEventAttributes } from 'nostr-editor'
    import cx from 'clsx';
    import { NodeViewWrapper } from 'svelte-tiptap';
	import EmbeddedEventWrapper from '$components/Events/EmbeddedEventWrapper.svelte';

    export let node: NodeViewProps['node']
    export let updateAttributes: NodeViewProps['updateAttributes']
  // export let deleteNode: NodeViewRendererProps['deleteNode']

    $: attrs = node.attrs as NEventAttributes

    let naddr: string;

    $: try {
        if (attrs.naddr) {
            if (attrs.naddr.match(/:/)) {
                naddr = attrs.naddr.split(/:/)[1];
            } else {
                naddr = attrs.naddr;
            }
        }
    } catch {}
</script>

<NodeViewWrapper data-type="naddr" as="span">
    {#if naddr}
        <EmbeddedEventWrapper id={naddr} />
    {:else}
        Naddr
        <pre>{JSON.stringify(attrs, null ,4)}</pre>
    {/if}
</NodeViewWrapper>