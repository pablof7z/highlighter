<script lang="ts">
	import { NDKArticle, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ArticleCard from "./ArticleCard.svelte";
	import { ndk } from "@kind0/ui-common";
	import UserProfile from "./User/UserProfile.svelte";

    export let tag: NDKTag;
    export let highlights: NDKHighlight[] = [];

    let article: NDKArticle;
    
    $ndk.fetchEvent(tag[1]).then(event => {
        if (event) article = NDKArticle.from(event);
    });
</script>

{#if article}
    <UserProfile user={article.author} let:userProfile>
        <ArticleCard
            title={article.title}
            image={article.image ?? userProfile?.image}
            description={article.summary}
            author={article.author}
            href={article.url}
            {highlights}
        />
    </UserProfile>
{/if}