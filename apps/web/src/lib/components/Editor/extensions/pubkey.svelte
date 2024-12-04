<script lang="ts">
    import type { NodeViewProps } from '@tiptap/core';
    import type { NEventAttributes } from 'nostr-editor'
    import cx from 'clsx';
    import { NodeViewWrapper } from 'svelte-tiptap';
	import Name from '$components/User/Name.svelte';

    export let node: NodeViewProps['node']
    export let selected: boolean = false;
    export let updateAttributes: NodeViewProps['updateAttributes']
  // export let deleteNode: NodeViewRendererProps['deleteNode']

    $: attrs = node.attrs as NEventAttributes

    let pubkey: string;

    $: try {
        if (attrs.pubkey) {
            if (attrs.pubkey.match(/:/)) {
                pubkey = attrs.pubkey.split(/:/)[1];
            } else {
                pubkey = attrs.pubkey;
            }
        }
    } catch {}
</script>

<NodeViewWrapper data-type="pubkey" as="span">
    {#if pubkey}
        <button class="mention {selected ? 'bg-secondary border-b border-primary' : ''}">
            <Name {pubkey} class="mention" />
        </button>
    {:else}
        Pubkey
        {attrs}
        <pre>{JSON.stringify(attrs, null ,4)}</pre>
    {/if}
</NodeViewWrapper>