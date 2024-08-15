<script lang="ts">
	import DraftItem from "$components/Creator/DraftItem.svelte";

    export let item: DraftItem;
</script>

<pre>{JSON.stringify(item, null, 2)}</pre>