<script lang="ts">
	import { layout } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NDKArticle, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import { setContext } from "svelte";
	import { Navigation } from "$utils/navigation";
	import { Readable } from "svelte/store";
    import GroupFooterJoin from "$components/Groups/Footer/Join.svelte";
	import { roundedItemCount } from "$utils/numbers";
	import { House } from "phosphor-svelte";

    export let group: NDKSimpleGroup;
    export let isAdmin: Readable<boolean>;
    export let isMember: Readable<boolean>;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let admins: Readable<NDKSimpleGroupMemberList | undefined>;
    export let members: Readable<NDKSimpleGroupMemberList | undefined>;
    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let articles: Readable<NDKArticle[]>;
    
    setContext('group', group);
    setContext("groupMetadata", metadata);
    setContext("groupAdmins", admins);
    setContext("groupMembers", members);
    setContext("isAdmin", isAdmin);
    setContext("isMember", isMember);
    setContext("groupTiers", tiers);
    setContext("groupArticles", articles);

    let options: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => options = value);

    optionManager.setOption('home', { id: 'home', icon: House, iconProps: { weight: 'fill' }, href: getGroupUrl(group) }, undefined, true);

    optionManager.setOption('chat', { name: "Chat", href: getGroupUrl(group, "chat") });
    optionManager.setOption('posts', { name: "Posts", href: getGroupUrl(group, "posts") });
    if ($isAdmin) {
        optionManager.setOption('settings', { name: "Settings", href: getGroupUrl(group, "settings") });
    }

    $: if ($articles.length > 0) optionManager.setOption('articles', { id: 'articles', name: "Articles", badge: roundedItemCount($articles!), href: getGroupUrl(group, "articles") }, true);

    $: if ($metadata) {
        $layout.title = $metadata.name ?? "Untitled group";
        $layout.iconUrl = $metadata.picture;
    }

    $: $layout.navigation = options;

    $: if ($isMember === false) {
        if ($metadata && $layout.footer?.component !== GroupFooterJoin) {
            $layout.footer = {
                component: GroupFooterJoin,
                props: {
                    group,
                    metadata,
                    admins,
                    members,
                    tiers,
                },
            }
        }
    } else if ($layout.footer?.component === GroupFooterJoin) {
        $layout.footer = undefined;
    }
</script>

{$articles?.length}

<slot
    {group}
    {metadata}
    {admins}
    {members}
    {isAdmin}
    {isMember}
    {tiers}
/>