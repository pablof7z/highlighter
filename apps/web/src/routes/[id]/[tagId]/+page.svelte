<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";

    let tagId: string;

    $: tagId = $page.params.tagId;
</script>

{#key tagId}
    <ItemView {tagId} />
{/key}
