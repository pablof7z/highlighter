import { SvelteRenderer } from 'svelte-tiptap';
import tippy from 'tippy.js';

import List from './list.svelte';
import { get } from 'svelte/store';
import { ndk } from '$stores/ndk';
import { userFollows } from '$stores/session';
import { searchUser } from '$utils/search/user';

const dummyData = ['test', 'mention', 'hashtag'];

export default function () {
  return {
    items: async ({ query }) => {
        const $ndk = get(ndk);
        const $userFollows = get(userFollows);
        const result = await searchUser(query, $ndk, $userFollows);

        console.log('result', result);

        return result.slice(0, 5)
        
    //   return dummyData
    //     .filter((item) => item.toLowerCase().startsWith(query.toLowerCase()))
    //     .slice(0, 5);
    },
    render: () => {
      let wrapper;
      let component;
      let renderer;
      let popup;

      return {
        onStart: (props) => {
          const { editor } = props;

          wrapper = document.createElement('div');
          editor.view.dom.parentNode?.appendChild(wrapper);

          component = new List({
            target: wrapper,
            props: {
              items: props.items,
              callback: (item) => {
                props.command({ id: item.pubkey + "a", label: "nostr:"+item.npub });
              },
            },
          });

          renderer = new SvelteRenderer(component, { element: wrapper });

          popup = tippy('body', {
            getReferenceClientRect: props.clientRect,
            appendTo: () => document.body,
            content: renderer.dom,
            showOnCreate: true,
            interactive: true,
            trigger: 'manual',
            placement: 'bottom-start',
          });
        },
        onUpdate: (props) => {
          renderer.updateProps(props);
          popup[0].setProps({
            getReferenceClientRect: props.clientRect,
          });
        },
        onKeyDown: (props) => {
          if (props.event.key === 'Escape') {
            popup[0].hide();
            return true;
          }
          return component.onKeyDown(props.event);
        },
        onExit: (props) => {
          const range = {
            from: props.editor.state.selection.from,
            to: props.editor.state.selection.from + props.query.length,
          };
          props.editor.commands.setTextSelection(range);
          props.editor.commands.deleteSelection();
          popup[0].destroy();
          renderer.destroy();
          wrapper.remove();
        },
      };
    },
  };
}
