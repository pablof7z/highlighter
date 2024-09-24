<script lang="ts">
	import FeaturedCommunityCard from '$components/Card/FeaturedCommunityCard.svelte';
	import { NDKSimpleGroupMetadata, NDKTag } from '@nostr-dev-kit/ndk';
	import { mainContentKinds } from '$utils/event';
	import { derived } from 'svelte/store';
	import { NDKRelaySet } from '@nostr-dev-kit/ndk';
	import { NDKKind } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';
	import { layout } from "$stores/layout";
    import * as Card from "$components/ui/card";
	import { Button } from "$components/ui/button";
	import { ArrowRight } from "phosphor-svelte";
    import * as Groups from "$components/Groups";

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

<Card.Root class="w-72 bg-secondary">
    <Card.Header>
        <Card.Title>
            Introducing Publications
        </Card.Title>
    </Card.Header>

    <Card.Content class="text-muted-foreground text-sm">
        <p>Publications are communities that
            encompass a specific topic.</p>
        
        <p></p>
    </Card.Content>

    <Card.Footer>
        <Button>
            Create Your Publication
            <ArrowRight class="ml-2" />
        </Button>
    </Card.Footer>
</Card.Root>

{#each $communities as community (community.id)}
    <p>{community.name}</p>
{/each}

<Groups.RootList tags={$groupTags} let:group>
    <FeaturedCommunityCard {group} />
</Groups.RootList>