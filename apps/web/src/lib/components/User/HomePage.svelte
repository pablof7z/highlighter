<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import NDK, { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKList, NDKRelaySet, NDKUser, NDKUserProfile, NDKVideo, getRelayListForUser, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { derived, writable, type Readable } from "svelte/store";
	import { getContext, onDestroy, onMount } from "svelte";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import * as Chat from "$components/Chat";
    import * as Card from '$components/Card';
	import HighlightBody from '$components/HighlightBody.svelte';
	import currentUser from '$stores/currentUser';

    export let user: NDKUser = getContext('user') as NDKUser;
    export let userProfile: NDKUserProfile | undefined | null;
    export let authorUrl: string;

    const userHighlights = getContext('userHighlights') as Readable<NDKHighlight[]>;
    const userArticles = getContext('userArticles') as Readable<NDKArticle[]>;
    const userNotes = getContext('userNotes') as Readable<NDKEvent[]>;
    const userVideos = getContext('userVideos') as Readable<NDKVideo[]>;
    const userGroupsList = getContext('userGroupsList') as Readable<NDKList>;
    const userPinList = getContext('userPinList') as Readable<NDKList>;

    let isCurrentUser: boolean | undefined;
    $: isCurrentUser = $currentUser?.pubkey === user.pubkey;

    let content: NDKEventStore<NDKEvent>;

    onDestroy(() => {
        if (content) content.unsubscribe();
        if (events) events.unsubscribe();
    })

    let events: NDKEventStore<NDKEvent>;

    let priorityBlocks: string[] = [];
    let priorityBlocksSet = new Set<string>();

    let blocks: string[] = [];
    let blockSet = new Set<string>();

    function isOp(event: NDKEvent) {
        return event.getMatchingTags("e").length === 0;
    }

    const highQualityNotes = derived(userNotes, $userNotes => {
        return $userNotes.filter(isOp);
    });

    $: {
        if ($userArticles.length > 0 && !priorityBlocksSet.has("articles")) {
            priorityBlocksSet.add("articles");
            priorityBlocks = [...priorityBlocks, "articles"]
        }

        if ($userVideos.length > 0 && !priorityBlocksSet.has("videos")) {
            priorityBlocksSet.add("videos");
            priorityBlocks = [...priorityBlocks, "videos"]
        }

        if ($userHighlights.length > 0 && !blockSet.has("highlights")) {
            blockSet.add("highlights");
            blocks = [...blocks, "highlights"]
        }

        if ($userGroupsList && $userGroupsList.items.length > 0 && !blockSet.has("groups")) {
            blockSet.add("groups");
            blocks = [...blocks, "groups"]
        }

        if ($highQualityNotes.length > 0 && !blockSet.has("notes")) {
            blockSet.add("notes");
            blocks = [...blocks, "notes"]
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
    <div class="flex flex-col gap-4 responsive-padding max-w-[100vw]">
        {#each $featuredItems as item}
            <Card.FeaturedItem item={item} skipAuthor />
        {/each}
    </div>
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
    {:else if block === "notes" && $highQualityNotes}
        <HorizontalList title="Notes" items={$highQualityNotes} let:item>
            <Card.Note event={item} />
        </HorizontalList>
    {:else if block === "groups" && $userGroupsList}
        <Chat.List>
            {#each $userGroupsList.items as item (item)}
                <Chat.Item tag={item} />
            {/each}
        </Chat.List>
    {/if}
{/each}
