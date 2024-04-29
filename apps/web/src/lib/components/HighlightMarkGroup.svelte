<script lang="ts">
    import {computePosition, autoUpdate, offset, flip } from 'https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.6.3/+esm';
	import { Avatar } from "@kind0/ui-common";
    import { NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from 'svelte';

    export let mark: HTMLElement;
    export let highlights: NDKEvent[];

    let groupEl: HTMLDivElement;
    let top;

    function updatePosition() {
        computePosition(mark, groupEl, {
            placement: 'left-start',
            offset: 10,
            middleware: [offset(10), flip()]
        }).then(({x, y}) => {
            Object.assign(groupEl.style, {
                top: y + 'px',
                left: 0 + 'px'
            })
            top = y;
        });
    }

    $: if (groupEl && highlights) updatePosition();

    let cleanup: any;

    onMount(() => {
        cleanup = autoUpdate(mark, groupEl, updatePosition);
    })

    onDestroy(() => {
        cleanup();
    })
</script>

<div bind:this={groupEl} class="absolute flex flex-col -space-y-4 z-50 -translate-x-10">
    {#each highlights as highlight}
        <Avatar user={highlight.author} size="small" type="circle"  />
    {/each}
</div>

<div class="hidden top-0 top-10 top-20"></div>