<script lang="ts">
	import { toggleFollow } from "$utils/user/follow";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { Actions, ActionsGroup, ActionsButton } from "konsta/svelte";

    export let opened = false;
    export let following = false;
    export let user: NDKUser;
</script>

<Actions
    {opened}
    onBackdropClick={() => {(opened = false)}}
>
    <ActionsGroup>
        {#if !following}
            <ActionsButton onClick={() => toggleFollow(user)} bold>Follow</ActionsButton>
        {/if}
        <ActionsButton onClick={() => {}}>Subscribe</ActionsButton>
    </ActionsGroup>

    <ActionsGroup>
        {#if following}
            <ActionsButton class="text-red-500" onClick={() => toggleFollow(user)}>Unfollow</ActionsButton>
        {:else}
            <ActionsButton class="text-red-500" onClick={() => {}}>
                Mute
            </ActionsButton>
        {/if}
    </ActionsGroup>

    <ActionsGroup>
        <ActionsButton onClick={() => {(opened = false)}}>
            Cancel
        </ActionsButton>
    </ActionsGroup>
</Actions>