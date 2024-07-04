<script lang="ts">
	import { page } from "$app/stores";
	import WithGroup from "$components/Event/WithGroup.svelte";
	import JoinGroupFooter from "$components/JoinGroupFooter.svelte";
	import { groupView, loadedGroup } from "$stores/item-view";
	import { pageHeader } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NavigationOption } from "../../app";

    let groupId: string;
    let relays: string[];

    $: {
        const r = $page.url.searchParams.get('relays');
        if (r) {
            relays = r.split(',');
        }
    }

    $: groupId = $page.params.groupId ?? $page.url.searchParams.get('groupId');

    $: if ($loadedGroup) {
        const opts: NavigationOption[] = [];

        opts.push({ name: "Chat", href: getGroupUrl($loadedGroup, "/chat") });
        opts.push({ name: "Posts", href: getGroupUrl($loadedGroup, "/posts") });

        if ($groupView.isAdmin) {
            opts.push({ name: "Settings", href: getGroupUrl($loadedGroup, "/settings") });
        }

        $pageHeader = {
            left: { label: "Back", url: "/communities" },
            title: $loadedGroup.name ?? "Community",
            subNavbarOptions: opts,
        };
    }

    $: if ($loadedGroup && $groupView.isMember === false) {
        $pageHeader.footer = {
            component: JoinGroupFooter,
            props: { group: $loadedGroup },
        }
    }
</script>



<WithGroup
    {groupId}
    {relays}
    bind:group={$loadedGroup}
    bind:isMember={$groupView.isMember}
    bind:isAdmin={$groupView.isAdmin}
>
    {#if $loadedGroup}
        <slot />
    {:else}
        nope
    {/if}
</WithGroup>