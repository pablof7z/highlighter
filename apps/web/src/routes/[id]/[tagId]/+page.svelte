<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "./ItemView.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;
</script>

{#key tagId}
    <ItemView />
{/key}