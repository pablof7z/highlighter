<script lang="ts">
    import {computePosition, autoUpdate, offset, flip } from '@floating-ui/dom';
	import Avatar from '$components/User/Avatar.svelte';
    import { NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from 'svelte';

    export let mark: HTMLElement;
    export let highlights: NDKEvent[];

    let groupEl: HTMLDivElement;
    let top;

    // function updatePosition() {
    //     computePosition(mark, groupEl, {
    //         placement: 'right-start',
    //         offset: 10,
    //         middleware: [offset(10), flip()]
    //     }).then(({x, y}) => {
    //         Object.assign(groupEl.style, {
    //             top: y + 'px',
    //             right: 0 + 'px'
    //         })
    //         top = y;
    //     });
    // }

    // $: if (groupEl && highlights) updatePosition();

    let cleanup: any;

    onMount(() => {
        // cleanup = autoUpdate(mark, groupEl, updatePosition);
        // remove groupEl from the DOM and insert it right after the mark
        mark.before(groupEl);
    })

    onDestroy(() => {
        // cleanup();
    })
</script>

<div bind:this={groupEl} class="absolute right-0 translate-x-full w-max flex flex-col -space-y-4 z-10">
    {#each highlights as highlight}
        <Avatar user={highlight.author} size="small" type="circle"  />
    {/each}
</div>