<script lang="ts">
	import { NDKKind, NDKUser, NDKList, NDKHighlight, NDKEvent, NDKArticle, NDKVideo, NDKWiki, NDKUserProfile, NDKSubscriptionTier, NDKSimpleGroup, NDKRelaySet, NDKTag, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
	import { derived, writable } from "svelte/store";
	import { ndk } from "$stores/ndk";
    import { deriveStore, deriveListStore } from "$utils/events/derive.js";
	import { filterArticle } from "$utils/article-filter";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | undefined | null;
    export let authorUrl: string;
    export let fetching: boolean;

    let eosed = false;
    const onEose = () => eosed = true;

    $ndk.outboxTracker!.track(user);

    const events = $ndk.storeSubscribe([
        { kinds: [ NDKKind.Text, NDKKind.GroupNote, NDKKind.GroupReply ], authors: [user.pubkey], limit: 50 },
        { kinds: [ NDKKind.Article ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.Wiki ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], authors: [user.pubkey], limit: 10 },
        { kinds: [ NDKKind.Highlight ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.TierList, NDKKind.SimpleGroupList, NDKKind.PinList ], authors: [user.pubkey] },
        { kinds: [ NDKKind.SubscriptionTier ], authors: [user.pubkey], limit: 100 },
    ], { subId: 'user-events', groupable: false, onEose });

    const highlights = deriveStore<NDKHighlight>(events, NDKHighlight)
    const notes = deriveStore<NDKEvent>(events, undefined, [NDKKind.Text, NDKKind.Repost, NDKKind.GenericRepost, NDKKind.GroupNote, NDKKind.GroupReply]);
    const articlesAll = deriveStore<NDKArticle>(events, NDKArticle);
    const videos = deriveStore<NDKVideo>(events, NDKVideo);
    const wiki = deriveStore<NDKWiki>(events, NDKWiki);
    const groupsList = deriveListStore<NDKList>(events, NDKList, [NDKKind.SimpleGroupList]);
    const pinList = deriveListStore<NDKList>(events, NDKList, [NDKKind.PinList]);
    const tierList = deriveListStore<NDKList>(events, NDKList, [NDKKind.TierList]);
    const allTiers = deriveStore<NDKSubscriptionTier>(events, NDKSubscriptionTier);

    const articles = derived(articlesAll, $articlesAll => {
        return $articlesAll.filter(filterArticle);
    });

    const groups = writable<Record<string, NDKSimpleGroup>>({});
    const groupsMetadata = writable<Record<string, NDKSimpleGroupMetadata>>({});

    // load groups
    let loadedGroups = new Set<string>();
    $: if ($groupsList && $groupsList.items) {
        for (const group of $groupsList.items) {
            const groupId = group[1];
            if (!loadedGroups.has(groupId)) {
                loadedGroups.add(groupId);
                loadGroup(group);
            }
        }
    }

    async function loadGroup(tag: NDKTag) {
        const [ _, groupId, relay ] = tag;
        const relaySet = NDKRelaySet.fromRelayUrls([relay], $ndk);
        const group = new NDKSimpleGroup($ndk, relaySet, groupId);
        group.getMemberListEvent();
        group.getMetadata().then((metadata) => {
            groupsMetadata.update(groups => {
                groups[groupId] = metadata;
                return groups;
            });
        });

        groups.update(groups => {
            groups[groupId] = group;
            return groups;
        });
    }

    const tiers = derived([tierList, allTiers], ([$tierList, $userAllTiers]) => {
        if (!$tierList) return [];

        const eTags = $tierList.getMatchingTags("e").map(t => t[1]);
        return $userAllTiers
            .filter(tier => eTags.includes(tier.id))
            // .filter(tier => tier.tagValue("h"))
    });
</script>

<slot
    {user}
    {notes}
    {highlights}
    {articles}
    {videos}
    {wiki}
    {groupsList}
    {pinList}
    {tierList}
    {tiers}
    {groups}
    {groupsMetadata}
    {eosed}
/>