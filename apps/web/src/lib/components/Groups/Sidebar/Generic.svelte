<script lang="ts">
    import * as Groups from "$components/Groups";
	import { groupsList } from "$stores/session";
    import currentUser from '$stores/currentUser';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { NDKKind, NDKRelaySet, NDKSimpleGroupMemberList, NDKTag } from "@nostr-dev-kit/ndk";
	import { Tray } from "phosphor-svelte";
	import { Button } from "$components/ui/button";

    const defaultGroups: NDKTag[] = [
        [ "group", "group55869", "wss://relay.highlighter.com/"]
    ]

    // let groupsUserAdmins: NDKEventStore<NDKSimpleGroupMemberList>;
    // let groupsTags: Readable<NDKTag[]>;
        
    // $: if (!groupsUserAdmins && $currentUser) {
    //     groupsUserAdmins = $ndk.storeSubscribe([
    //         { kinds: [ NDKKind.GroupMembers], "#p": [$currentUser.pubkey] }
    //     ], { relaySet: NDKRelaySet.fromRelayUrls([
    //         "wss://devrelay.highlighter.com",
    //         "wss://relay.0xchat.com",
    //         "wss://groups.fiatjaf.com",
    //     ], $ndk)})

    //     groupsTags = derived(groupsUserAdmins, $groupsUserAdmins => {
    //         console.log($groupsUserAdmins)
            
    //         return $groupsUserAdmins.map(list => [ "group", list.dTag!, list.relay?.url ])
    //     })
    // }
</script>

{#if $groupsList && $groupsList.items.length > 0}
    <div class="divide-y divide-border flex flex-col border-b">
        <Groups.RootList tags={$groupsList.items} let:group>
            <Groups.ListItem {group} />
        </Groups.RootList>
    </div>
{:else}
    <Groups.RootList tags={defaultGroups} let:group>
        <Groups.ListItem {group} />
    </Groups.RootList>

    <div class="divide-y divide-border flex flex-col border-b">
    </div>

    <div class="flex flex-col items-center gap-6 h-full justify-center">
        <Tray class="text-muted-foreground" size={48} />

        
        <div class="text-muted-foreground text-sm">
            You are not following any publications
        </div>

        <div class="text-muted-foreground font-light text-sm">
            Once you follow a publication, it will appear here.p
        </div>

        <Button variant="secondary" href="/groups">
            Explore Publications
        </Button>
        
    </div>

{/if}
<!-- 
{#if $groupsUserAdmins}
    {$groupsUserAdmins.length}
    <Groups.RootList tags={$groupsTags} let:group>
        <Groups.ListItem {group} />
    </Groups.RootList>
{/if} -->