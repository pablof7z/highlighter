<script lang="ts">
	import { Component, footerMainView, layout } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NDKArticle, NDKEvent, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKVideo, NDKWiki } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import { setContext } from "svelte";
	import { Navigation } from "$utils/navigation";
	import { roundedItemCount } from "$utils/numbers";
	import { House } from "phosphor-svelte";
    import * as Groups from "$components/Groups";
	import { Readable } from "svelte/store";

    export let group: Readable<Groups.GroupData>;
    export let articles: Readable<NDKArticle[]>;
    export let videos: Readable<NDKVideo[]>;
    export let wiki: Readable<NDKWiki[]>;
    export let notes: Readable<NDKEvent[]>;
    export let chat: Readable<NDKEvent[]>;

    setContext('group', group);
    setContext('groupArticles', articles);

    let navigation: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => navigation = value);

    setContext("optionManager", optionManager);

    optionManager.setOption('home', { id: 'home', icon: House, iconProps: { weight: 'fill' }, href: getGroupUrl($group) }, undefined, true);

    optionManager.setOption('chat', {
        name: "Chat",
        badge: roundedItemCount($chat!),
        buttonProps: { disabled: !$group.isMember },
        href: $group.isMember ? getGroupUrl($group, "chat") : undefined
    });
    optionManager.setOption('posts', {
        name: "Posts",
        badge: roundedItemCount($notes!),
        buttonProps: { disabled: !$group.isMember },
        href: $group.isMember ? getGroupUrl($group, "posts") : undefined
    });
    if ($group.isAdmin) {
        optionManager.setOption('settings', { name: "Settings", href: getGroupUrl($group, "settings") });
    }

    $: if ($articles.length > 0) optionManager.setOption('articles', { id: 'articles', name: "Articles", badge: roundedItemCount($articles!), href: getGroupUrl($group, "articles") }, true);
    $: if ($videos.length > 0) optionManager.setOption('videos', { id: 'videos', name: "Videos", badge: roundedItemCount($videos!), href: getGroupUrl($group, "videos") }, true);

    $layout.sidebar = {
        component: Groups.Sidebars.Generic,
    }

    $: {
        $layout.title = $group.name ?? "Untitled group";
        $layout.back = { url: '/communities' };

        if ($group.isMember === false) {
            $layout.options = [
                {
                    name: "Join",
                    fn: () => {
                        $footerMainView = 'main'
                    },
                    buttonProps: {
                        variant: "accent",
                        class: "px-6 ml-4"
                    }
                }
            ]
        } else {
            $layout.options = undefined;
        }
    }

    $: $layout.navigation = navigation;

    let prevFooter: Component | undefined;

    function setFooter() {
        prevFooter = $layout.footer;
        $layout.footer = {
            component: Groups.Footers.Join,
            props: {
                group,
            },
        }
    }

    $: {
        if ($group.isMember === false) {
            setFooter();
        } else {
            
        }
    }
</script>

<slot
    {group}
    {articles}
    {videos}
    {wiki}
    {notes}
    {chat}
    {tiers}
    {navigation}
/>