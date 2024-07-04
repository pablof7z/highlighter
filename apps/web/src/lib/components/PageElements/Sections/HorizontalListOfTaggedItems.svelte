<script lang="ts">
	import ArticleGridArticle from '$components/ArticleGridArticle.svelte';
	import ArticleGridUrlItem from '$components/ArticleGridUrlItem.svelte';
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { articleKinds } from '$utils/event';
	import { NDKArticle, NDKEvent, NDKHighlight } from '@nostr-dev-kit/ndk';
	import { onMount } from 'svelte';
	import { Readable, writable } from 'svelte/store';

    export let highlights: Readable<NDKHighlight[]>;

    onMount(() => {
        const fetchedTags = new Set<string>();
        for (const highlight of $highlights) {
            const tag = highlight.getArticleTag()
            if (!tag) continue;
            if (fetchedTags.has(tag[1])) continue;
            fetchedTags.add(tag[1]);
            if (fetchedTags.size > 30) break;
            highlight.getArticle().then(article => {
                if (article instanceof NDKEvent && articleKinds.includes(article.kind!)) {
                    taggedItems.update(taggedItems => {
                        return [...taggedItems, NDKArticle.from(article)];
                    });
                } else if (typeof article === "string") {
                    taggedItems.update(taggedItems => {
                        return [...taggedItems, {id: article}];
                    });
                }
            });
        }
    })

    const taggedItems = writable<(NDKEvent | {id: string})[]>([]);



    export let title: string;
</script>

{$taggedItems.length}
<HorizontalList {title} items={$taggedItems} let:item>
    {#if item instanceof NDKArticle}
        <ArticleGridArticle article={item} />
    {:else}
        <ArticleGridUrlItem url={item.id} />
    {/if}
</HorizontalList>