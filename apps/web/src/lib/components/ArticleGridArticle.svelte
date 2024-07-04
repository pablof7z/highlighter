<script lang="ts">
	import { NDKArticle, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ArticleCard from "./ArticleCard.svelte";
	import { ndk } from "$stores/ndk.js";
	import UserProfile from "./User/UserProfile.svelte";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let article: NDKArticle | undefined = undefined;
    export let tag: NDKTag | undefined = undefined;
    export let highlights: NDKHighlight[] = [];

    let url: string;
    let authorUrl: string;
    
    if (!article && tag)
        $ndk.fetchEvent(tag[1]).then(event => {
            if (event) {
                article = NDKArticle.from(event);
            }
        });

    $: if (article) {
        const suffix = urlSuffixFromEvent(article);
        if (authorUrl && suffix.length > 0)
            url = [authorUrl, suffix].join('/')
        else
            url = `a/${article.encode()}`
    }
</script>

{#if article}
    <UserProfile user={article.author} let:userProfile bind:authorUrl>
        <ArticleCard
            title={article.title}
            image={article.image ?? userProfile?.image}
            description={article.summary}
            author={article.author}
            href={urlFromEvent(article)}
            {highlights}
            {...$$props}
        />
    </UserProfile>
{/if}