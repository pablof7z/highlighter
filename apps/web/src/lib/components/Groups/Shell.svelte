<script lang="ts">
	import currentUser from '$stores/currentUser';
	import JoinGroupFooter from "$components/JoinGroupFooter.svelte";
	import { groupView, loadedGroup } from "$stores/item-view";
	import { layout } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NDKFilter, NDKKind, NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import { ndk } from "$stores/ndk";
	import { deriveListStore, deriveStore } from "$utils/events/derive";
	import { setContext } from "svelte";
	import { Navigation } from "$utils/navigation";
	import { derived } from "svelte/store";

    export let tag: NDKTag | undefined = undefined;
    export let groupId: string | undefined = undefined;
    export let relays: string[] | undefined = undefined;

    if (tag) {
        groupId = tag[1];
        relays = tag.slice(2, tag.length);
    }

    groupId ??= "";

    const hFilter: NDKFilter = { "#h": [groupId] };
    const dFilter: NDKFilter = { "#d": [groupId] };

    const relaySet = NDKRelaySet.fromRelayUrls(relays||[], $ndk);

    const group = new NDKSimpleGroup($ndk, relaySet, groupId);

    // Subscriptions
    const events = $ndk.storeSubscribe([
        // { kinds: [ NDKKind.GroupNote, NDKKind.GroupReply ], ...hFilter, limit: 50 },
        // { kinds: [ NDKKind.Article ], ...hFilter, limit: 100 },
        // { kinds: [ NDKKind.Wiki ], ...hFilter, limit: 100 },
        // { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], ...hFilter, limit: 100 },
        // { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], ...hFilter, limit: 10 },
        // { kinds: [ NDKKind.Highlight ], ...hFilter, limit: 100 },
        // { kinds: [ NDKKind.TierList, NDKKind.PinList ], ...hFilter },
        { kinds: [ NDKKind.GroupMetadata, NDKKind.GroupAdmins, NDKKind.GroupMembers ], ...dFilter },
    ], { subId: 'group-events', groupable: false, relaySet });

    const events2 = $ndk.storeSubscribe([
        { kinds: [ NDKKind.SubscriptionTier ], ...hFilter, limit: 100 },
    ], { subId: 'group-events-2', groupable: false, relaySet });

    // Derivations
    const groupMetadata = deriveListStore(events, NDKSimpleGroupMetadata);
    const groupAdmins = deriveListStore(events, NDKSimpleGroupMemberList, [NDKKind.GroupAdmins]);
    const groupMembers = deriveListStore(events, NDKSimpleGroupMemberList);
    const groupTiers = deriveStore(events2, NDKSubscriptionTier);
    
    const isAdmin = derived(
        [ currentUser, groupAdmins ], ([ $currentUser, $groupAdmins ]) => {
            if ($currentUser && $groupAdmins) {
                console.log('comparing admin', $groupAdmins, $currentUser.pubkey)
                return $groupAdmins.hasMember($currentUser.pubkey);
            }
            return false;
        }
    );
    const isMember = derived(
        [ currentUser, groupMembers ], ([ $currentUser, $groupMembers ]) => {
            if ($currentUser && $groupMembers) {
                return $groupMembers.hasMember($currentUser.pubkey);
            }
            return false;
        }
    );

    // setContext('group', group);
    // setContext("groupMetadata", groupMetadata);
    // setContext("groupAdmins", groupAdmins);
    // setContext("isAdmin", isAdmin);
    // setContext("isMember", isMember);
    setContext("groupTiers", groupTiers);

    $: console.log('group tiers', $groupTiers)

    let options: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => options = value);

    optionManager.setOption('chat', { name: "Chat", href: getGroupUrl(group, "chat") });
    optionManager.setOption('posts', { name: "Posts", href: getGroupUrl(group, "posts") });
    if ($isAdmin) {
        optionManager.setOption('settings', { name: "Settings", href: getGroupUrl(group, "settings") });
    }

    $: if ($groupMetadata) {
        $layout.title = $groupMetadata.name ?? "Untitled group";
        $layout.iconUrl = $groupMetadata.picture;
    }


    $: $layout.navigation = options;

    $: if ($isMember === false) {
        $layout.footer = {
            component: JoinGroupFooter,
            props: { group },
        }
    }
</script>

<slot {group}
    metadata={$groupMetadata} {groupAdmins} {isAdmin} {isMember}
    tiers={$groupTiers}
/>