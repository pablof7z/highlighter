<script lang="ts">
import currentUser from "$stores/currentUser";
    import { categorizedUserLists, sortedUserLists, userFollows } from "$stores/session";
	import { ndk } from "$stores/ndk.js";
    import { NDKUser } from "@nostr-dev-kit/ndk";
	import { Checkbox } from "konsta/svelte";
	import { Plus, User, UserPlus } from "phosphor-svelte";

    export let user: NDKUser;

    async function follow() {
        const currentFollows = new Set<NDKUser>();
        $userFollows.forEach((pubkey) => currentFollows.add($ndk.getUser({ pubkey })));
        $currentUser?.follow(user, currentFollows);
    }

    async function unfollow() {
        const currentFollows = new Set<NDKUser>();
        $userFollows.forEach((pubkey) => currentFollows.add($ndk.getUser({ pubkey })));
        $currentUser?.unfollow(user, currentFollows);
    }
</script>

{#if $currentUser?.pubkey !== user.pubkey}
    <div class="dropdown dropdown-hover z-50 dropdown-end">
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
        <ul class="dropdown-content bg-base-300 menu flex flex-col items-start whitespace-nowrap">
            {#each $sortedUserLists as list}
                <li>
                    <button class="flex flex-row items-center gap-2 w-full">
                        {#if list.items.map(t => t[1]).includes(user.pubkey)}
                            <Checkbox class="w-5 h-5 text-success" />
                        {:else}
                            <Plus class="w-5 h-5 text-zinc-500" />
                        {/if}
                        <span class="whitespace-nowrap">{list.name}</span>
                    </button>
                </li>
            {/each}
        </ul>
    </div>
{/if}
