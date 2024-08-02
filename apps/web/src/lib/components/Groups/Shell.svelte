<script lang="ts">
	import { Component, layout } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NDKArticle, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import { setContext } from "svelte";
	import { Navigation } from "$utils/navigation";
	import { Readable } from "svelte/store";
	import { roundedItemCount } from "$utils/numbers";
	import { House } from "phosphor-svelte";
    import * as Group from "$components/Groups";

    export let group: NDKSimpleGroup;
    export let isAdmin: Readable<boolean>;
    export let isMember: Readable<boolean>;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let admins: Readable<NDKSimpleGroupMemberList | undefined>;
    export let joinRequests: Readable<NDKEvent[]>;
    export let members: Readable<NDKSimpleGroupMemberList | undefined>;
    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let stores: Group.ContentStores;

    const { articles, videos, wiki, notes, chat } = stores;
    
    setContext('group', group);
    setContext("groupMetadata", metadata);
    setContext("groupAdmins", admins);
    setContext("groupMembers", members);
    setContext("isAdmin", isAdmin);
    setContext("isMember", isMember);
    setContext("joinRequests", joinRequests);
    setContext("groupTiers", tiers);
    setContext("groupArticles", articles);
    setContext("groupVideos", videos);
    setContext("groupWiki", wiki);
    setContext("groupNotes", notes);
    setContext("groupChat", chat);

    let options: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => options = value);

    optionManager.setOption('home', { id: 'home', icon: House, iconProps: { weight: 'fill' }, href: getGroupUrl(group) }, undefined, true);

    optionManager.setOption('chat', { name: "Chat", badge: roundedItemCount($chat!), href: getGroupUrl(group, "chat") });
    optionManager.setOption('posts', { name: "Posts", href: getGroupUrl(group, "posts") });
    if ($isAdmin) {
        optionManager.setOption('settings', { name: "Settings", href: getGroupUrl(group, "settings") });
    }

    $: if ($articles.length > 0) optionManager.setOption('articles', { id: 'articles', name: "Articles", badge: roundedItemCount($articles!), href: getGroupUrl(group, "articles") }, true);
    $: if ($videos.length > 0) optionManager.setOption('videos', { id: 'videos', name: "Videos", badge: roundedItemCount($videos!), href: getGroupUrl(group, "videos") }, true);

    $: {
        $layout.title = $metadata?.name ?? "Untitled group";
        $layout.iconUrl = $metadata?.picture;
        $layout.back = { url: '/communities' };
    }

    $: $layout.navigation = options;

    let prevFooter: Component | undefined;

    function setFooter() {
        prevFooter = $layout.footer;
        $layout.footer = {
            component: Group.Footers.Join,
            props: {
                group,
                metadata,
                admins,
                members,
                tiers,
                isMember,
            },
        }
    }

    $: {
        if ($isMember === false) {
            setFooter();
        }
    }
</script>

<slot
    {group}
    {metadata}
    {admins}
    {joinRequests}
    {members}
    {isAdmin}
    {isMember}
    {tiers}
/>