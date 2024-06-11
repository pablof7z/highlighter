<script lang="ts">
	import BookmarkFeed from "./BookmarkFeed.svelte";
	import { page } from "$app/stores";

    let value: string;
    
    $: value = $page.params.mode ?? "You";
</script>

{#key value}
    <BookmarkFeed type={value} />
{/key}