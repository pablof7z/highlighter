<script lang="ts">
    import { userFollows } from "$stores/session";
	import { ndk } from "$stores/ndk.js";
    import { NDKUser } from "@nostr-dev-kit/ndk";
	import { Plus, User, UserMinus, UserPlus } from "phosphor-svelte";
	import { Button } from "$components/ui/button";
	import currentUser from "$stores/currentUser";

    export let user: NDKUser;
    export let isFollowed: boolean | undefined = undefined;

    isFollowed = $userFollows.has(user.pubkey);

    async function follow() {
        const currentFollows = new Set<NDKUser>();
        $userFollows.forEach((pubkey) => currentFollows.add($ndk.getUser({ pubkey })));
        $currentUser?.follow(user, currentFollows);
        isFollowed = true;
    }

    async function unfollow() {
        const currentFollows = new Set<NDKUser>();
        $userFollows.forEach((pubkey) => currentFollows.add($ndk.getUser({ pubkey })));
        $currentUser?.unfollow(user, currentFollows);
        isFollowed = false;
    }

    function clicked() {
        if (isFollowed) {
            unfollow();
        } else {
            follow();
        }
    }
</script>

<Button
    variant="accent"
    class="flex-none{$$props.class??""}"
    on:click={clicked}
>
    {#if isFollowed}
        <UserMinus class="w-4 h-4 mr-2" weight="bold" />
        Unfollow
    {:else}
        <Plus class="w-4 h-4 mr-2" weight="bold" />
        Follow
    {/if}
</Button>