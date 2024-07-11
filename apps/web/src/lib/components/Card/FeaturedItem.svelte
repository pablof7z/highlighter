<script lang="ts">
	import { NDKArticle, NDKSimpleGroup, NDKVideo } from "@nostr-dev-kit/ndk";
	import FeaturedArticleCard from "./FeaturedArticleCard.svelte";
	import FeaturedCommunityCard from "./FeaturedCommunityCard.svelte";
	import UrlCard from "./UrlCard.svelte";
	import VideoCard from "./VideoCard.svelte";

    export let item: NDKArticle | NDKVideo | NDKSimpleGroup | string;
</script>

{#if item instanceof NDKArticle}
    <FeaturedArticleCard article={item} {...$$props} />
{:else if item instanceof NDKSimpleGroup}
    <FeaturedCommunityCard group={item} {...$$props} />
{:else if item instanceof NDKVideo}
    <VideoCard video={item} {...$$props} />
{:else if typeof item === "string"}
    <UrlCard url={item} {...$$props} />
{/if}