<script lang="ts">
	import LayoutHeaderNavigation from '$components/Layout/Headers/LayoutHeaderNavigation.svelte';
	import WithGroup from "$components/Event/WithGroup.svelte";
	import JoinGroupFooter from "$components/JoinGroupFooter.svelte";
	import { groupView, loadedGroup } from "$stores/item-view";
	import { layout, pageHeader } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NavigationOption } from "../../../app";

    export let groupId: string;
    export let relays: string[];

    $: if ($loadedGroup) {
        const opts: NavigationOption[] = [];

        opts.push({ name: "Chat", href: getGroupUrl($loadedGroup, "chat") });
        opts.push({ name: "Posts", href: getGroupUrl($loadedGroup, "posts") });

        if ($groupView.isAdmin) {
            opts.push({ name: "Settings", href: getGroupUrl($loadedGroup, "settings") });
        }

        $layout.title = $loadedGroup.name ?? "Untitled group";
        $layout.iconUrl = $loadedGroup.picture;
        $layout.navigation = opts;
    }

    $: if ($loadedGroup && $groupView.isMember === false) {
        $layout.footer = {
            component: JoinGroupFooter,
            props: { group: $loadedGroup },
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
            <slot />
        {/if}
    </WithGroup>
{/key}