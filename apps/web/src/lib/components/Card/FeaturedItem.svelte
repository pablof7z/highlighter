<script lang="ts">
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import FeaturedArticleCard from "./FeaturedArticleCard.svelte";
	import UrlCard from "./UrlCard.svelte";
	import VideoCard from "./VideoCard.svelte";

    export let item: NDKArticle | NDKVideo | string;
</script>

{#if item instanceof NDKArticle}
    <FeaturedArticleCard article={item} {...$$props} />
{:else if item instanceof NDKVideo}
    <VideoCard video={item} {...$$props} />
{:else if typeof item === "string"}
    <UrlCard url={item} {...$$props} />
{/if}