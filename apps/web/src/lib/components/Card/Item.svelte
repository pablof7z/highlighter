<script lang="ts">
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import ArticleCard from "./ArticleCard.svelte";
	import UrlCard from "./UrlCard.svelte";
	import VideoCard from "./VideoCard.svelte";

    export let item: NDKArticle | NDKVideo | string;
</script>

{#if item instanceof NDKArticle}
    <ArticleCard article={item} {...$$props} />
{:else if item instanceof NDKVideo}
    <VideoCard video={item} {...$$props} />
{:else if typeof item === "string"}
    <UrlCard url={item} {...$$props} />
{/if}