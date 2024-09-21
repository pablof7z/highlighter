import { Node, mergeAttributes } from '@tiptap/core';
import { SvelteNodeViewRenderer } from 'svelte-tiptap';

import Nevent from './nevent.svelte';
import { nip19 } from 'nostr-tools';
import { EventPointer } from '@nostr-dev-kit/ndk';

export const NeventExtension = Node.create({
    name: 'nevent',
    group: 'block',
    atom: true,
    draggable: true,
    inline: false,
  
    addAttributes() {
      return {
        id: {
          default: 0,
        },
      };
    },
  
    parseHTML() {
        return [{ tag: `div[data-type="${this.name}"]` }]
    },

    renderHTML({ HTMLAttributes }) {
        return ['div', mergeAttributes(HTMLAttributes)];
    },

    addNodeView() {
        return SvelteNodeViewRenderer(Nevent);
    },

    addCommands() {
        return {
          insertNEvent:
            ({ nevent }) =>
            ({ commands }) => {
              const parts = nevent.split(':')
              const attrs = nip19.decode(parts[parts.length - 1])?.data as EventPointer
                return commands.insertContent(
                    { type: this.name, attrs: { ...attrs, nevent } },
                    { updateSelection: false, },
                )
            },
        }
    },
});