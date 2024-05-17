<script lang="ts">
	import { page } from "$app/stores";
	import { layoutMode, layoutNavState, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";
	import { EventType } from "../../../app";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;

    $layoutMode = "content-focused";
    $layoutNavState = "collapsed";

    onDestroy(resetLayout);
</script>

{#key tagId}
    <ItemView {tagId} />
{/key}
