<script lang="ts">
    import type { NodeViewProps } from '@tiptap/core';
    import cx from 'clsx';
    import { NodeViewWrapper } from 'svelte-tiptap';
  
    export let node: NodeViewProps['node'];
    export let updateAttributes: NodeViewProps['updateAttributes'];
  
    const handleClick = () => {
      updateAttributes({ count: node.attrs.count + 1 });
    };
  </script>
  
  <NodeViewWrapper>
    <span>Svelte Component</span>
  
    <div>
      <button on:click={handleClick} type="button">
        This button has been clicked {node.attrs.count} times.
      </button>
    </div>
</NodeViewWrapper>