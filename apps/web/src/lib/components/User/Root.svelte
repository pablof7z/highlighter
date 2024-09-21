<script lang="ts">
	import { NDKKind, NDKUser, NDKList, NDKHighlight, NDKEvent, NDKArticle, NDKVideo, NDKWiki, NDKUserProfile, NDKSubscriptionTier, NDKSimpleGroup, NDKRelaySet, NDKTag, NDKSimpleGroupMetadata, NDKCashuMintList } from "@nostr-dev-kit/ndk";
	import { derived, writable } from "svelte/store";
	import { ndk } from "$stores/ndk";
    import { deriveStore, deriveListStore } from "$utils/events/derive.js";
	import { filterArticle, filterArticles } from "$utils/article-filter";
	import UserProfile from "./UserProfile.svelte";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | undefined | null = undefined;
    export let authorUrl: string | undefined = undefined;
    export let fetching: boolean | undefined = undefined;

    let eosed = false;
    const onEose = () => eosed = true;

    $ndk.outboxTracker!.track(user);

    const events = $ndk.storeSubscribe([
        { kinds: [ NDKKind.GroupNote, NDKKind.GroupReply ], authors: [user.pubkey], limit: 50 },
        { kinds: [ NDKKind.Article ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], authors: [user.pubkey], limit: 10 },
        { kinds: [ NDKKind.Highlight ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.ArticleCurationSet ], authors: [user.pubkey] },
        { kinds: [ NDKKind.TierList, NDKKind.SimpleGroupList, NDKKind.PinList, NDKKind.CashuMintList ], authors: [user.pubkey] },
        { kinds: [ NDKKind.SubscriptionTier ], authors: [user.pubkey], limit: 100 },

        // mint list
        { kinds: [ NDKKind.CashuMintList ], authors: [user.pubkey], limit: 100 },
    ], { subId: 'user-events', groupable: false, onEose });

    const highlights = deriveStore<NDKHighlight>(events, NDKHighlight)
    const notes = deriveStore<NDKEvent>(events, undefined, [NDKKind.Text, NDKKind.Repost, NDKKind.GenericRepost, NDKKind.GroupNote, NDKKind.GroupReply]);
    const articlesAll = deriveStore<NDKArticle>(events, NDKArticle);
    const videos = deriveStore<NDKVideo>(events, NDKVideo);
    const wiki = deriveStore<NDKWiki>(events, NDKWiki);
    const groupsList = deriveListStore<NDKList>(events, NDKList, [NDKKind.SimpleGroupList]);
    const pinList = deriveListStore<NDKList>(events, NDKList, [NDKKind.PinList]);
    const tierList = deriveListStore<NDKList>(events, NDKList, [NDKKind.TierList]);
    const curations = deriveStore<NDKList>(events, NDKList, [NDKKind.ArticleCurationSet]);
    const cashuMintList = deriveListStore<NDKCashuMintList>(events, NDKCashuMintList);
    const allTiers = deriveStore<NDKSubscriptionTier>(events, NDKSubscriptionTier);

    const articles = filterArticles(articlesAll);

    const tiers = derived([tierList, allTiers], ([$tierList, $userAllTiers]) => {
        if (!$tierList) return [];

        const eTags = $tierList.getMatchingTags("e").map(t => t[1]);
        return $userAllTiers
            .filter(tier => eTags.includes(tier.id))
            // .filter(tier => tier.tagValue("h"))
    });

    const shouldFetchUserProfile = userProfile === undefined && !fetching;
</script>

{#if shouldFetchUserProfile}
    <UserProfile {user} bind:userProfile bind:authorUrl  bind:fetching />
{/if}

<slot
    {user}
    {notes}
    {highlights}
    {articles}
    {videos}
    {wiki}
    {groupsList}
    {curations}
    {cashuMintList}
    {pinList}
    {tierList}
    {tiers}
    {eosed}
    {userProfile}
    {fetching}
    {authorUrl}
/>