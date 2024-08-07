<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { filterArticles } from "$utils/article-filter";
	import { NDKArticle, NDKFilter, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import * as Feed from "$components/Feed";
	import { CaretRight, MagnifyingGlass } from "phosphor-svelte";

    const relaySet = NDKRelaySet.fromRelayUrls(['wss://relay.highlighter.com'], $ndk);

    const articleComments = $ndk.storeSubscribe([
        { kinds: [NDKKind.Text, NDKKind.Zap, NDKKind.Nutzap ], "#k": ["30023"], limit: 50 },
        { kinds: [NDKKind.ArticleCurationSet ], limit: 10 },
    ], { closeOnEose: true, onEose: () => {
        loadArticles();
    }})

    let articles: NDKEventStore<NDKArticle>;

    function loadArticles() {
        const filter: NDKFilter = {kinds:[NDKKind.Article], authors:[], "#d": [], limit: 200};

        $articleComments.forEach(comment => {
            const aTag = comment.getMatchingTags("a")
                .filter(tag => tag[1].startsWith("30023:"))
                ?.[0]?.[1];
            
            if (aTag) {
                const [kind, pubkey, dTag] = aTag.split(":");
                if (dTag.length > 0) {
                    filter.authors!.push(pubkey);
                    filter["#d"]!.push(dTag);
                }
            }
        });

        console.log({filter})

        if (filter.authors!.length > 0) {
            articles = $ndk.storeSubscribe(
                filter,
                { subId: 'articles' },
                NDKArticle
            );
        }
    }
</script>

{#if articles}
    <div class="flex flex-col w-full max-w-[var(--content-focused-width)]">
        <a href="/reads" class="flex flex-row justify-between max-sm:w-full py-2 responsive-padding z-10 bg-background border-b border-border">
            <div class="section-title">
                Nostr Reads
            </div>

            <CaretRight size={24} />
        </a>

        <Feed.Articles
            store={filterArticles(articles)}
        />
        <a href="/reads" class="bg-secondary flex flex-row justify-between max-sm:w-full py-4 responsive-padding">
            <div>
                <MagnifyingGlass size={24} class="inline" />
                Explore more great reads
            </div>

            <CaretRight size={24} />
        </a>
    </div>
{/if}