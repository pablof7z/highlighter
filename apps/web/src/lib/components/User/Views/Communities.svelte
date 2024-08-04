<script lang="ts">
	import { layout } from "$stores/layout";
	import { NDKKind, NDKList, NDKUser } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy } from "svelte";
	import { derived, Readable } from 'svelte/store';
    import * as Groups from "$components/Groups";
    import * as Chat from "$components/Chat";

    export let user: NDKUser = getContext("user") as NDKUser;
    export let userGroupsList = getContext("userGroupsList") as Readable<NDKList | undefined>;

    $layout.fullWidth = false;
</script>

<div class="responsive-padding">
    {#if $userGroupsList}
        <Groups.RootList tags={$userGroupsList.items} let:groupEntry>
            <Chat.Item {groupEntry} />
        </Groups.RootList>
    {/if}
</div>

<!-- 
<div class="responsive-padding">
    {#each $loadedGroups as group (group.groupId)}
        <Chat.Item groupEntry={group} />
    {/each}
</div> -->
