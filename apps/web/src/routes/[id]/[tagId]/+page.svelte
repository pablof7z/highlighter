<script lang="ts">
	import type { EventType } from './../../../../app.d.ts';
	import { page } from "$app/stores";
	import { layoutMaxWidth, layoutMode, layoutNavState, mainAlign, pageMainContentMaxWidth, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";
	import ItemView from './ItemView.svelte';

    let tagId: string;
    let eventType: EventType | undefined;

    $: tagId = $page.params.tagId;

    $layoutMaxWidth = "max-w-none";
    $pageMainContentMaxWidth = "max-w-3xl";
    $mainAlign = "center";
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
