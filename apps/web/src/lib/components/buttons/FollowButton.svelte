<script lang="ts">
	import currentUser from "$stores/currentUser";
    import { userFollows } from "$stores/session";
	import { ndk } from "@kind0/ui-common";
    import { NDKUser } from "@nostr-dev-kit/ndk";
	import { User, UserPlus } from "phosphor-svelte";

    export let user: NDKUser;

    async function follow() {
        const currentFollows = new Set<NDKUser>();
        $userFollows.forEach((pubkey) => currentFollows.add($ndk.getUser({ pubkey })));
        await $currentUser?.follow(user, currentFollows);
    }

    async function unfollow() {
        const currentFollows = new Set<NDKUser>();
        $userFollows.forEach((pubkey) => currentFollows.add($ndk.getUser({ pubkey })));
        await $currentUser?.unfollow(user, currentFollows);
    }
</script>

{#if $currentUser?.pubkey !== user.pubkey}
    {#if !$userFollows.has(user.pubkey)}
        <span class="tooltip" data-tip="Follow">
            <button class="btn btn-circle transition-all duration-300 {$$props.class??""}" on:click={follow}>
                <User size={24} />
            </button>
        </span>
    {:else}
        <span class="tooltip" data-tip="Unfollow">
            <button class="btn btn-circle transition-all duration-300 {$$props.class??""}" on:click={unfollow}>
                <UserPlus size={24} />
            </button>
        </span>
    {/if}
{/if}

<style lang="postcss">
    button {
        @apply bg-base-300;
        @apply hover:bg-white/20 transition-all duration-300;
    }
</style>
