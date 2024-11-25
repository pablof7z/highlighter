<script lang="ts">
	import FeaturedCommunityCard from '$components/Card/FeaturedCommunityCard.svelte';
	import { NDKSimpleGroupMetadata, NDKTag } from '@nostr-dev-kit/ndk';
	import { mainContentKinds } from '$utils/event';
	import { derived, get } from 'svelte/store';
	import { NDKRelaySet } from '@nostr-dev-kit/ndk';
	import { NDKKind } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';
	import { layout } from "$stores/layout";
    import * as Card from "$components/Card";
	import { Button } from "$components/ui/button";
	import { ArrowRight } from "phosphor-svelte";
    import * as Groups from "$components/Groups";
	import StoreFeed from '$components/Feed/StoreFeed.svelte';

    $layout.sidebar = false;
    $layout.fullWidth = false;

    const relaySet = NDKRelaySet.fromRelayUrls([
        "wss://relay.highlighter.com",
        "wss://relay.0xchat.com",
        "wss://groups.fiatjaf.com",
        "ws://localhost:2929"
    ], $ndk)

    const articles = $ndk.storeSubscribe({kinds: mainContentKinds}, { relaySet, closeOnEose: true})
    const articlesWithHTag = derived(articles, $articles => $articles.filter(a => a.hasTag("h")))

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
    
    const communities = $ndk.storeSubscribe({
        kinds: [NDKKind.GroupMetadata]
    }, { relaySet, closeOnEose: true}, NDKSimpleGroupMetadata);
    const tags = derived(communities, $communities => {
        return $communities.map(community => {
            return [ "group", community.dTag!, community.relay?.url ]
        })
    })
</script>

<div class="flex flex-row gap-4 w-full overflow-x-auto">
    <Groups.RootList tags={$groupTags} let:group let:articles>
        {#if articles && get(articles).length > 0}
            <Card.Community {group} />
        {/if}
    </Groups.RootList>
</div>

<StoreFeed feed={articlesWithHTag} />

<!-- 
<Groups.RootList tags={$groupTags} let:group let:articles>
    {#if articles && get(articles).length > 0}
        <Groups.MoreFrom {group} {articles} />
    {/if}
</Groups.RootList> -->