<script lang="ts">
    import * as Card from '$components/Card';
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { articleKinds } from '$utils/event';
	import { NDKArticle, NDKEvent, NDKHighlight, NDKVideo } from '@nostr-dev-kit/ndk';
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
            }).catch(e => {});
        }
    })

    const taggedItems = writable<(NDKEvent | {id: string})[]>([]);



    export let title: string;
</script>

<HorizontalList {title} items={$taggedItems} let:item>
    {#if item instanceof NDKArticle}
        <Card.Article article={item} />
    {:else if item instanceof NDKVideo}
        <Card.Video video={item} />
    {:else}
        <Card.Url url={item.id} />
    {/if}
</HorizontalList>