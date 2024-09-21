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

    let nevent: string;

    $: try {
        if (attrs.nevent) {
            if (attrs.nevent.match(/:/)) {
                nevent = attrs.nevent.split(/:/)[1];
            } else {
                nevent = attrs.nevent;
            }
        }
    } catch {}
</script>

<NodeViewWrapper data-type="nevent" as="span">
    {#if nevent}
        <EmbeddedEventWrapper id={nevent} />
    {:else}
        Nevent
        {attrs.nevent}
        <pre>{JSON.stringify(attrs, null ,4)}</pre>
    {/if}
</NodeViewWrapper>