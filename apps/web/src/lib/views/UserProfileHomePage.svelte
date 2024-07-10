<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { ndk } from "$stores/ndk.js";
	import NDK, { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKList, NDKRelaySet, NDKUser, NDKUserProfile, NDKVideo, getRelayListForUser, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { derived, writable, type Readable } from "svelte/store";
	import { onDestroy, onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import * as Chat from "$components/Chat";
    import * as Card from '$components/Card';
	import { userArticles, userGroupList, userHighlights, userPinList, userVideos } from '$stores/user-view';
	import HighlightBody from '$components/HighlightBody.svelte';
	import currentUser from '$stores/currentUser';
    import * as User from "$components/User";

    export let user: NDKUser;

    let isCurrentUser: boolean | undefined;
    $: isCurrentUser = $currentUser?.pubkey === user.pubkey;

    $ndk.outboxTracker!.track(user);

    onMount(() => {
        addReadReceipt(user);
    })

    let content: NDKEventStore<NDKEvent>;

    onDestroy(() => {
        if (content) content.unsubscribe();
        if (events) events.unsubscribe();
    })

    let events: NDKEventStore<NDKEvent>;
    let feed: Readable<NDKEvent[]>;

    $: {
        if (events) events.unsubscribe();

        events = $ndk.storeSubscribe([
            { kinds: [NDKKind.Text], authors: [user.pubkey] },
        ], {
            repostsFilters: [ { kinds: [NDKKind.Repost], authors: [user.pubkey] } ]
        });

        feed = derived(events, $events => {
            const events: NDKEvent[] = [];

            for (const event of $events) {
                if (event.kind === NDKKind.Text) {
                    if (isEventOriginalPost(event))
                        events.push(event);
                } else {
                    events.push(event);
                }
            }

            // Sort by date
            events.sort((a, b) => b.created_at! - a.created_at!);

            return events;
        });
    }

    let userProfile: NDKUserProfile | undefined = undefined;
    let authorUrl: string;

    // const highlights = $ndk.storeSubscribe({
    //     kinds: [NDKKind.Highlight], authors: [user.pubkey], limit: 50
    // }, {
    //     relaySet: highlighterRelaySet,
    //     onEose: () => {
    //         console.log('fetch', $highlights.length)
    //         for (const highlight of $highlights) {
    //             highlight.getArticle().then(article => {
    //                 console.log('fetch', article)
    //                 if (article instanceof NDKEvent) {
    //                     reads.update(reads => {
    //                         if (reads.find(a => a.pubkey === article.pubkey)) return reads;
    //                         return [...reads, NDKArticle.from(article)];
    //                     });
    //                 }
    //             });
    //         }
    //     }
    // }, NDKHighlight);
    // const reads = writable<NDKArticle[]>([]);

    let groupsList: NDKList | undefined;
    $ndk.fetchEvent({kinds: [NDKKind.SimpleGroupList], authors: [user.pubkey]}).then(list => {
        if (list) groupsList = NDKList.from(list);
    });

    const pinboards = $ndk.storeSubscribe({
        kinds: [33889], authors: [user.pubkey], limit: 50
    });

    let priorityBlocks: string[] = [];
    let priorityBlocksSet = new Set<string>();

    let blocks: string[] = [];
    let blockSet = new Set<string>();

    $: {
        if ($userArticles && $userArticles.length > 0 && !blockSet.has("articles")) {
            priorityBlocksSet.add("articles");
            priorityBlocks = [...priorityBlocks, "articles"]
        }

        if ($userVideos && $userVideos.length > 0 && !blockSet.has("videos")) {
            priorityBlocksSet.add("videos");
            priorityBlocks = [...priorityBlocks, "videos"]
        }

        if ($userHighlights && $userHighlights.length > 0 && !blockSet.has("highlights")) {
            blockSet.add("highlights");
            blocks = [...blocks, "highlights"]
        }

        if ($userGroupList && $userGroupList.items.length > 0 && !blockSet.has("groups")) {
            blockSet.add("groups");
            blocks = [...blocks, "groups"]
        }
    }

    let featuredItems: Readable<(NDKArticle | NDKVideo)[]> | undefined;

    $: if (!featuredItems && userArticles && userVideos && userPinList) {
        featuredItems = derived([ userArticles, userVideos, userPinList ], ([ $userArticles, $userVideos, $userPinList ]) => {
            const items: (NDKArticle | NDKVideo)[] = [];
            if (!$userPinList) return items;

            for (const pin of $userPinList.items) {
                const tag = pin[1];
                const kind = tag.split(/:/)[0];
                let lookIn: NDKEvent[] | undefined;

                if (kind === NDKKind.Article.toString()) {
                    lookIn = $userArticles;
                    console.log('lookin in articles', $userArticles?.length)
                } else if (kind === NDKKind.HorizontalVideo.toString()) {
                    lookIn = $userVideos;
                }

                console.log('looking for pin', tag)
                if (lookIn) {
                    const item = lookIn.find(e => e.tagId() === tag);
                    if (item) items.push(item as NDKArticle | NDKVideo);
                }
            }

            return items;
        })
    }
</script>

<svelte:head>
    <title>{userProfile?.name}</title>
    <meta name="description" content="Creator profile" />
    <meta property="og:title" content={user.npub} />
    <meta property="og:description" content="Creator profile" />
    {#if userProfile?.banner}
        <meta property="og:image" content={userProfile.banner} />
    {/if}
</svelte:head>

<!-- <UserProfile {user} bind:userProfile bind:authorUrl /> -->
{#if featuredItems && $featuredItems}
    {#if $featuredItems.length === 1}
        <Card.Item item={$featuredItems[0]} />
    {:else if $featuredItems.length > 1}
        <HorizontalList title="Featured" items={$featuredItems} let:item>
            <Card.Item item={item} />
        </HorizontalList>
    {/if}
{/if}

{#each priorityBlocks as block}
    {#if block === "videos"}
        <HorizontalList title="Videos" items={$userVideos} let:item>
            <Card.Video video={item} />
        </HorizontalList>
    {:else if block === "articles"}
        <HorizontalList title="Articles" items={$userArticles} let:item>
            <Card.Article article={item} skipAuthor />
        </HorizontalList>
    {/if}
{/each}

{#each blocks as block}
    {#if block === "highlights"}
        <HorizontalList title="Highlights" items={$userHighlights} let:item>
            <HighlightBody highlight={item} />
        </HorizontalList>
    {:else if block === "groups" && $userGroupList}
        <Chat.List>
            {#each $userGroupList.items as item (item)}
                <Chat.Item tag={item} />
            {/each}
        </Chat.List>
    {/if}
{/each}

{#if $pinboards.length > 0}
    <HorizontalList title="Pinboards" items={$pinboards} let:item>
        <Card.Content
            title={item.tagValue("d")}
            image={item.tagValue("image")}
            description={item.tagValue("description")}
            author={item.author}
            href="/a?eventId={item.encode()}"
            skipAuthor
        />
    </HorizontalList>
{/if}
