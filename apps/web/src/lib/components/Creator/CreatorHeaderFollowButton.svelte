<script lang="ts">
	import { appMobileView } from "$stores/app";
    import currentUser from "$stores/currentUser";
    import { sortedUserLists, userFollows } from "$stores/session";
    import { ndk } from "@kind0/ui-common";
    import { NDKUser } from "@nostr-dev-kit/ndk";
    import { Checkbox } from "konsta/svelte";
    import { Check, Plus, User, UserPlus } from "phosphor-svelte";

    export let user: NDKUser;
    export let collapsed = false;

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
    <div class="dropdown dropdown-hover z-50 dropdown-end">
        {#if !$userFollows.has(user.pubkey)}
            <button class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col"} items-center gap-1" on:click={follow}>
                <Plus class="" size={$appMobileView ? 25 : 20} weight="bold" />
                <span class="text-xs {collapsed ? "max-sm:hidden" : ""}">Follow</span>
            </button>
        {:else}
            <button class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col"} items-center gap-1 text-accent2 hover:grayscale" on:click={unfollow}>
                <Check class="" size={$appMobileView ? 25 : 20} weight="bold" />
                <span class="text-xs {collapsed ? "max-sm:hidden" : ""}">Following</span>
            </button>
        {/if}
        <ul class="dropdown-content bg-base-300 menu flex flex-col items-start whitespace-nowrap">
            {#each $sortedUserLists as list}
                <li>
                    <button class="flex flex-row items-center gap-2 w-full">
                        {#if list.items.map(t => t[1]).includes(user.pubkey)}
                            <Checkbox class="w-6 h-6 sm:w-5 sm:h-5 text-success" />
                        {:else}
                            <Plus class="w-6 h-6 sm:w-5 sm:h-5 text-zinc-500" />
                        {/if}
                        <span class="whitespace-nowrap">{list.name}</span>
                    </button>
                </li>
            {/each}
        </ul>
    </div>
{/if}
