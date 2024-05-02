<script lang="ts">
	import type { EventType } from './../../../../app.d.js';
	import { page } from "$app/stores";
	import { layoutMode, layoutNavState, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";
	import ItemView from './ItemView.svelte';

    let tagId: string;
    let eventType: EventType | undefined;

    $: tagId = $page.params.tagId;

    $layoutNavState = "collapsed";

    onDestroy(resetLayout);

    $: switch (eventType) {
        case 'curation':
            $layoutMode = 'reversed-columns';
            break;
        default:
            $layoutMode = 'content-focused';
            break;
    }
</script>

{#key tagId}
    <ItemView bind:eventType />
{/key}
