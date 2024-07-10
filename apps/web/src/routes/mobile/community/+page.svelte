<script lang="ts">
	import LayoutHeaderNavigation from '$components/Layout/Headers/LayoutHeaderNavigation.svelte';
	import { page } from "$app/stores";
	import WithGroup from "$components/Event/WithGroup.svelte";
	import JoinGroupFooter from "$components/JoinGroupFooter.svelte";
	import { groupView, loadedGroup } from "$stores/item-view";
	import { layout, pageHeader } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import GroupChat from "$views/Groups/GroupChat.svelte";
	import GroupHomePage from "$views/Groups/GroupHomePage.svelte";
	import GroupPosts from "$views/Groups/GroupPosts.svelte";
	import GroupSettings from "$views/Groups/GroupSettings.svelte";
	import { NavigationOption } from "../../../app.d.js";

    let groupId: string;
    let relays: string[];
    let view: string;

    $: {
        const r = $page.url.searchParams.get('relays');
        if (r) {
            relays = r.split(',');
        }
    }

    $: groupId = $page.url.searchParams.get('groupId')!;
    $: view = $page.url.searchParams.get('view')!;

    $: if ($loadedGroup) {
        const opts: NavigationOption[] = [];

        opts.push({ name: "Chat", href: getGroupUrl($loadedGroup, "chat") });
        opts.push({ name: "Posts", href: getGroupUrl($loadedGroup, "posts") });

        if ($groupView.isAdmin) {
            opts.push({ name: "Settings", href: getGroupUrl($loadedGroup, "settings") });
        }

        // $pageHeader = {
        //     left: { label: "Back", url: "/communities" },
        //     title: $loadedGroup.name ?? "Community",
        //     subNavbarOptions: opts,
        // };

        $layout.navigation = opts;
    }

    $: if ($loadedGroup) {
        $layout.title = $loadedGroup.name ?? "Community";
        $layout.iconUrl = $loadedGroup.picture;
        if ($groupView.isMember === false) {
            $layout.footer = {
                component: JoinGroupFooter,
                props: { group: $loadedGroup },
            }
        }
    }
</script>

{#key groupId}
    <WithGroup
        {groupId}
        {relays}
        bind:group={$loadedGroup}
        bind:isMember={$groupView.isMember}
        bind:isAdmin={$groupView.isAdmin}
    >
        {#if $loadedGroup}
            {#if view === "posts"}
                <GroupPosts group={$loadedGroup} />
            {:else if view === "chat"}
                <GroupChat group={$loadedGroup} />
            {:else if view === "settings"}
                <GroupSettings group={$loadedGroup} />
            {:else}
                <GroupHomePage group={$loadedGroup} />
            {/if}

        {/if}
    </WithGroup>
{/key}