<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKSimpleGroupMetadata, NDKSimpleGroupMemberList, NDKRelaySet, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { onDestroy } from "svelte";

    export let tag: NDKTag | undefined = undefined;
    export let groupId: string | undefined = undefined;
    export let relays: string[] | undefined = undefined;

    if (tag) {
        groupId = tag[1];
        relays = tag.slice(2);
    }

    export let group: NDKSimpleGroup | undefined = undefined;   
    export let relaySet: NDKRelaySet | undefined = undefined;

    let metadataEvents: NDKEventStore<NDKSimpleGroupMetadata>;
    let admins: NDKEventStore<NDKSimpleGroupMemberList>;
    let members: NDKEventStore<NDKSimpleGroupMemberList>;
    
    $: if (groupId) {
        if (!relays) relaySet = undefined;
        else relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);

        group = new NDKSimpleGroup($ndk, relaySet, groupId);

        metadataEvents = $ndk.storeSubscribe({
            kinds: [NDKKind.GroupMetadata], "#d": [groupId]
        }, { relaySet }, NDKSimpleGroupMetadata);

        admins = $ndk.storeSubscribe({
            kinds: [NDKKind.GroupAdmins], "#d": [groupId]
        }, { relaySet }, NDKSimpleGroupMemberList);

        members = $ndk.storeSubscribe({
            kinds: [NDKKind.GroupMembers], "#d": [groupId]
        }, { relaySet }, NDKSimpleGroupMemberList);
    }

    onDestroy(() => {
        metadataEvents?.unsubscribe();
        members?.unsubscribe();
    })

    $: if ($metadataEvents?.[0]) {
        group.metadata = $metadataEvents[0];
        group = group;
    }

    $: if ($admins?.[0]) {
        group.adminList = $admins[0];
        group = group;

        if ($currentUser)
            isAdmin = $admins[0].hasMember($currentUser.pubkey)
        else
            isAdmin = false;
    }

    $: if ($members?.[0]) {
        group.memberList = $members[0];
        group = group;

        if ($currentUser)
            isMember = group.memberList.hasMember($currentUser.pubkey)
        else
            isMember = false;
    }

    /**
     * Whether current user is a member of this group
     */
    export let isMember: boolean | undefined = undefined;

    /**
     * Whether current user is an admin of this group
     */
    export let isAdmin: boolean | undefined = undefined;
</script>

{#if group}
    <slot {group} />
{:else}
    Trying to load {groupId} from {relays}
{/if}