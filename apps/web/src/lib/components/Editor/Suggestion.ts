import { SvelteRenderer } from 'svelte-tiptap';
import tippy from 'tippy.js';

import List from './list.svelte';
import { get } from 'svelte/store';
import { ndk } from '$stores/ndk';
import { userFollows } from '$stores/session';
import { searchUser } from '$utils/search/user';

export default function () {
  let q: string;
  
  return {
    items: async ({ query }) => {
        const $ndk = get(ndk);
        const $userFollows = get(userFollows);
        const result = await searchUser(query, $ndk, $userFollows);
        q = query;

        return result.slice(0, 5)
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
          wrapper.classList.add('suggestion-wrapper');
          editor.view.dom.parentNode?.appendChild(wrapper);

          component = new List({
            target: wrapper,
            props: {
              items: props.items,
              callback: (item) => {
                const user = get(ndk).getUser({pubkey: item.pubkey})
                const queryLength = q.length + 1;

                const range = {
                  from: props.editor.state.selection.from - queryLength,
                  to: props.editor.state.selection.from,
                };
                props.editor.commands.setTextSelection(range);
                props.editor.commands.deleteSelection();
                
                editor.commands.insertNProfile({nprofile: "nostr:"+user.nprofile })
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
          console.log('on exit', {props})
          // const range = {
          //   from: props.editor.state.selection.from,
          //   to: props.editor.state.selection.from + props.query.length,
          // };
          // props.editor.commands.setTextSelection(range);
          // props.editor.commands.deleteSelection();
          popup[0].destroy();
          renderer.destroy();
          wrapper.remove();
        },
      };
    },
  };
}
