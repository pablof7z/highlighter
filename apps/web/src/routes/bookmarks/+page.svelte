<script lang="ts">
	import BookmarkFeed from "./BookmarkFeed.svelte";
	import { page } from "$app/stores";
	import { pageNavigationOptionsValue } from "$stores/layout";
    import { PageTransition } from 'sveltekit-page-transitions'

    $pageNavigationOptionsValue = undefined;

    let value: string;
    
    $: value = $page.params.mode ?? "You";
</script>

<PageTransition>
{#key value}
    <BookmarkFeed type={value} />
{/key}
</PageTransition>