<script lang="ts">
	import { NDKArticle, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ArticleCard from "./ArticleCard.svelte";
	import { ndk } from "@kind0/ui-common";
	import UserProfile from "./User/UserProfile.svelte";

    export let tag: NDKTag;
    export let highlights: NDKHighlight[] = [];

    let article: NDKArticle;

    let url: string;
    let authorUrl: string;
    
    $ndk.fetchEvent(tag[1]).then(event => {
        if (event) {
            article = NDKArticle.from(event);
        }
    });

    $: if (article) url = authorUrl ? [authorUrl, article.tagValue("d")].join('/') : `a/${article.encode()}`
</script>

{#if article}
    <UserProfile user={article.author} let:userProfile bind:authorUrl>
        <ArticleCard
            title={article.title}
            image={article.image ?? userProfile?.image}
            description={article.summary}
            author={article.author}
            href={url}
            {highlights}
        />
    </UserProfile>
{/if}