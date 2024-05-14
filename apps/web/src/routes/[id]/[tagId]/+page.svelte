<script lang="ts">
	import { page } from "$app/stores";
	import { layoutMode, layoutNavState, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";
	import { EventType } from "../../../app";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";

    let tagId: string;
    let eventType: EventType | undefined;

    $: tagId = $page.params.tagId;

    $layoutNavState = "collapsed";

    onDestroy(resetLayout);

    $: switch (eventType) {
        case 'curation':
            $layoutMode = "content-focused";
            break;
        default:
            $layoutMode = 'content-focused';
            break;
    }
</script>

{#key tagId}
    <ItemView bind:eventType />
{/key}
