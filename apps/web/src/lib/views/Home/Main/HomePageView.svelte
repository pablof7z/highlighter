<script lang="ts">
	import FeaturedCommunityCard from '$components/Card/FeaturedCommunityCard.svelte';
	import { NDKArticle, NDKSimpleGroupMetadata, NDKTag } from '@nostr-dev-kit/ndk';
	import { chronologically, mainContentKinds } from '$utils/event';
	import { derived, get, Readable, writable, Writable } from 'svelte/store';
	import { NDKRelaySet } from '@nostr-dev-kit/ndk';
	import { NDKKind } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';
	import { setLayout } from "$stores/layout";
    import * as Card from "$components/Card";
    import * as Groups from "$components/Groups";
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { userFollows } from '$stores/session';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';

    setLayout({
        fullWidth: true
    });

    const relaySet = NDKRelaySet.fromRelayUrls([
        "wss://relay.highlighter.com",
        "wss://relay.0xchat.com",
        "wss://groups.fiatjaf.com",
        "ws://localhost:2929"
    ], $ndk)

    const articles = $ndk.storeSubscribe({kinds: [
        NDKKind.Article
    ]}, { relaySet, closeOnEose: true}, NDKArticle)
    const articlesWithHTag = derived(articles, $articles => $articles.filter(a => a.hasTag("h")))

    let articlesByFollows: Writable<NDKArticle[]> | NDKEventStore<NDKArticle> = writable([]);
    
    $: if ($userFollows.size > 0) {
        articlesByFollows = $ndk.storeSubscribe([
            { kinds: [ NDKKind.Article ], authors: Array.from($userFollows) },
        ], { closeOnEose: true, groupable: false }, NDKArticle);
    }

    const groupTags = derived(articlesWithHTag, $articles => {
        const tags = new Map<string, NDKTag>()
        $articles.map(article => {
            const hTag = article.tagValue("h")!
            const relayUrl = article.relay?.url
            if (!hTag || !relayUrl) return;
            tags.set(hTag, [ "group", hTag, relayUrl ])
        });

        return Array.from(tags.values());
    })
    
    const articlesToRender = derived([articlesWithHTag, articlesByFollows], ([$articlesWithHTag, $articlesByFollows]) => {
        const articles = new Map<string, NDKArticle>();

        $articlesWithHTag.forEach(a => articles.set(a.tagId(), a))
        $articlesByFollows.forEach(a => articles.set(a.tagId(), a))

        return Array.from(articles.values())
            .sort(chronologically)
    })
    
</script>

<div class="flex flex-row gap-4 w-full overflow-x-auto">
    <Groups.RootList tags={$groupTags} let:group let:articles>
        {#if articles && get(articles).length > 0}
            <Card.Community {group} />
        {/if}
    </Groups.RootList>
</div>

<div class="max-w-[var(--content-focused-width)] mx-auto">
    <StoreFeed feed={articlesToRender} />
</div>

<!-- 
<Groups.RootList tags={$groupTags} let:group let:articles>
    {#if articles && get(articles).length > 0}
        <Groups.MoreFrom {group} {articles} />
    {/if}
</Groups.RootList> -->