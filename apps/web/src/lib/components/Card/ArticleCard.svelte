<script lang="ts">
	import { NDKArticle, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";
	import { ndk } from "$stores/ndk.js";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";
	import { getSummary, readTime } from "$utils/article";
	import { Badge } from "$components/ui/badge";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import RelatedEvents from "$components/Feed/Item/RelatedEvents.svelte";

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

    let time: string;
    let summary: string | null;

    $: if (!time && article) time = readTime(article.content);
    $: if (summary === undefined && article) summary = getSummary(article) ?? null;
</script>

{#if article}
    <ContentCard
        title={article.title??"Untitled"}
        image={article.image}
        author={article.author}
        href={urlFromEvent(article)}
        description={summary}
        event={article}
        {highlights}
        {...$$props}
    >
        <div slot="tags">
            <Badge variant="secondary" class="font-normal text-muted-foreground !bg-black/50">
                {time} read
            </Badge>
        </div>
    </ContentCard>
{/if}