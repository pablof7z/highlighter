<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from "$stores/session";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { onDestroy, onMount } from "svelte";
	import { layout } from "$stores/layout";

    $layout = {
        title: "Notes",
        fullWidth: false
    };

    onDestroy(() => {
        $layout.fullWidth = undefined;
    });
    
    const authors = Array.from($userFollows);

    if ($currentUser) authors.push($currentUser.pubkey);

    let filters: NDKFilter[] ;
    
    onMount(() => {
        filters = [{
            kinds: [NDKKind.Text],
            authors, limit: 100
        }]
    });
</script>

{#if filters}
    <FilterFeed
        {filters}
        urlPrefix="/e/"
        renderLimit={1}
    />
{/if}