<script lang="ts">
	import { layout } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import { setContext } from "svelte";
	import { Navigation } from "$utils/navigation";
	import { Readable } from "svelte/store";
    import GroupFooterJoin from "$components/Groups/Footer/Join.svelte";

    export let group: NDKSimpleGroup;
    export let isAdmin: Readable<boolean>;
    export let isMember: Readable<boolean>;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let admins: Readable<NDKSimpleGroupMemberList | undefined>;
    export let members: Readable<NDKSimpleGroupMemberList | undefined>;
    export let tiers: Readable<NDKSubscriptionTier[]>;

    setContext('group', group);
    setContext("groupMetadata", metadata);
    setContext("groupAdmins", admins);
    setContext("groupMembers", members);
    setContext("isAdmin", isAdmin);
    setContext("isMember", isMember);
    setContext("groupTiers", tiers);

    let options: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => options = value);

    optionManager.setOption('chat', { name: "Chat", href: getGroupUrl(group, "chat") });
    optionManager.setOption('posts', { name: "Posts", href: getGroupUrl(group, "posts") });
    if ($isAdmin) {
        optionManager.setOption('settings', { name: "Settings", href: getGroupUrl(group, "settings") });
    }

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

<slot
    {group}
    {metadata}
    {admins}
    {members}
    {isAdmin}
    {isMember}
    {tiers}
/>