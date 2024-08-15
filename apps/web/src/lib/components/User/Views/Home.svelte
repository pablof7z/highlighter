<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import NDK, { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKList, NDKSubscriptionTier, NDKUser, NDKUserProfile, NDKVideo, getRelayListForUser, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { derived, writable, type Readable } from "svelte/store";
	import { getContext, onDestroy, onMount } from "svelte";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import * as Groups from "$components/Groups";
    import * as Card from '$components/Card';
	import currentUser from '$stores/currentUser';
	import { layout } from '$stores/layout';
	import RootList from '$components/Groups/RootList.svelte';

    export let user: NDKUser = getContext('user') as NDKUser;
    export let userProfile: NDKUserProfile | undefined | null = getContext('userProfile') as NDKUserProfile;
    export let authorUrl: string | undefined | null = getContext('authorUrl') as string;

    $layout.fullWidth = false;

    const userHighlights = getContext('userHighlights') as Readable<NDKHighlight[]>;
    const userArticles = getContext('userArticles') as Readable<NDKArticle[]>;
    const userNotes = getContext('userNotes') as Readable<NDKEvent[]>;
    const userVideos = getContext('userVideos') as Readable<NDKVideo[]>;
    const userGroupsList = getContext('userGroupsList') as Readable<NDKList>;
    const userPinList = getContext('userPinList') as Readable<NDKList>;
    const userTiers = getContext('userTiers') as Readable<NDKSubscriptionTier[]>;

    $layout.footerInMain = true;

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

        if ($highQualityNotes.length > 0 && !blockSet.has("notes")) {
            blockSet.add("notes");
            blocks = [...blocks, "notes"]
        }
    }

    let featuredItems: Readable<(NDKArticle | NDKVideo)[]> | undefined;

    $: if (!featuredItems && userArticles && userVideos && userPinList) {
        featuredItems = derived([ userArticles, userVideos, userPinList ], ([ $userArticles, $userVideos, $userPinList ]) => {
            const items: (NDKArticle | NDKVideo)[] = [];
            if (!$userPinList) {
                // get most recent articles or video
                const firstVideo = $userVideos[0];
                const firstArticle = $userArticles[0];
                let mostRecent: NDKVideo | NDKArticle;
                if (firstVideo && firstArticle) mostRecent = firstVideo?.created_at! > firstArticle?.created_at! ? firstVideo : firstArticle;
                mostRecent ??= firstVideo ?? firstArticle;
                if (mostRecent) {
                    items.push(mostRecent);
                }
                return items;
            }

            for (const pin of $userPinList.items) {
                const tag = pin[1];
                const [_kind, pubkey, id] = tag.split(/:/);
                const kind = _kind ? parseInt(_kind) : undefined;
                let lookIn: NDKEvent[] | undefined;

                if (kind === NDKKind.Article && $userArticles) {
                    lookIn = $userArticles;
                } else if (kind === NDKKind.HorizontalVideo && $userVideos) {
                    lookIn = $userVideos;
                } else if (kind === NDKKind.GroupMetadata) {
                    lookIn = undefined;
                    // if ($userGroupList[id]?.metadata?.name || $userGroupsMetadata[id].name) {
                    //     // $userGroups[id].metadata = $userGroupsMetadata[id];
                    //     items.push($userGroups[id]);
                    // }
                }

                if (lookIn) {
                    const item = lookIn.find(e => e.tagId() === tag);
                    if (item) {
                        items.push(item as NDKArticle | NDKVideo);
                    }
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

<div class="flex flex-col w-full divide-y divide-border">

    <!-- <UserProfile {user} bind:userProfile bind:authorUrl /> -->
    {#if $featuredItems && $featuredItems.length > 0}
        <div class="flex flex-col gap-4 responsive-padding max-w-[100vw] py-[var(--section-vertical-padding)]">
            {#each $featuredItems as item (item.id)}
                <Card.FeaturedItem item={item} skipAuthor />
            {/each}
        </div>
    {/if}

    {#if $userGroupsList}
        <Groups.RootList tags={$userGroupsList.items} let:group>
            <Card.Community
                {group}
            />
        </Groups.RootList>
    {/if}

    {#each priorityBlocks as block}
        {#if block === "videos"}
            <HorizontalList class="py-[var(--section-vertical-padding)]" title="Videos" items={$userVideos} let:item>
                <Card.Video video={item} />
            </HorizontalList>
        {:else if block === "articles"}
            <HorizontalList class="py-[var(--section-vertical-padding)]" title="Articles" items={$userArticles} let:item>
                <Card.Article article={item} skipAuthor />
            </HorizontalList>
        {/if}
    {/each}

    {#each blocks as block}
        {#if block === "highlights"}
            <HorizontalList class="py-[var(--section-vertical-padding)]" title="Highlights" items={$userHighlights} let:item>
                <Card.Highlight highlight={item} />
            </HorizontalList>
        {:else if block === "notes" && $highQualityNotes}
            <HorizontalList class="py-[var(--section-vertical-padding)]" title="Notes" items={$highQualityNotes} let:item>
                <Card.Note event={item} />
            </HorizontalList>
        {:else if block === "groups" && $userGroupsList}
            <!-- <Chat.List>
                {#each $userGroupsList.items as item (item)}
                    <Chat.Item tag={item} />
                {/each}
            </Chat.List> -->
        {/if}
    {/each}

</div>