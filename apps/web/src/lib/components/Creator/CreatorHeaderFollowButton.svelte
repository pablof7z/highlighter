<script lang="ts">
    import currentUser from "$stores/currentUser";
    import { muteList, sortedUserLists, userFollows } from "$stores/session";
    import { NDKUser } from "@nostr-dev-kit/ndk";
    import { Check, Cross, Plus, SpeakerNone, SpeakerX, User, UserPlus, X } from "phosphor-svelte";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import { ndk } from "$stores/ndk";

    export let user: NDKUser;
    export let collapsed = false;

    async function toggleFollow() {
        if ($userFollows.size === 0) {
            if (!confirm("We have not found any follows, if you continue and you currently following people your follows list will be emptied. Do you want to continue?")) {
                return;
            }
        }
        
        const currentFollows = new Set<NDKUser>();
        for (const pubkey of $userFollows) { currentFollows.add($ndk.getUser({pubkey}))}

        if (!$userFollows.has(user.pubkey)) {
            console.log("Following", currentFollows.size);
            $currentUser?.follow(user, currentFollows);
        } else {
            $currentUser?.unfollow(user, currentFollows);
        }
    }

    let following: boolean;

    $: following = $userFollows.has(user.pubkey);

    let open = false;
</script>

{#if $currentUser?.pubkey !== user.pubkey}
    <DropdownMenu.Root bind:open>
        <DropdownMenu.Trigger>
            {#if !following}
                <button class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col justify-between"} items-center gap-1" on:click={toggleFollow} on:mouseenter={() => {
                    open = true;
                }}>
                    <Plus class="{collapsed ? ("w-6 h-6") : ("w-9 h-9")}" weight="bold" />
                    <span class="{collapsed ? "max-sm:hidden text-sm" : "text-base"}">Follow</span>
                </button>
            {:else}
                <button class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col justify-between"} items-center gap-1 text-accent hover:grayscale" on:click={toggleFollow}>
                    <Check class="{collapsed ? ("w-6 h-6") : ("w-9 h-9")}" weight="bold" />
                    <span class="{collapsed ? "max-sm:hidden text-sm" : "text-base"}">Following</span>
                </button>
            {/if}
        </DropdownMenu.Trigger>
        <DropdownMenu.Content class="w-56">
            <DropdownMenu.Group>
                <DropdownMenu.Item>
                    <button class="flex flex-row items-center gap-2 w-full" on:click={toggleFollow}>
                        {#if following}
                            <X class="w-6 h-6 sm:w-5 sm:h-5 text-red-500" />
                            <span class="whitespace-nowrap text-red-500">Unfollow</span>
                        {:else}
                            <Plus class="w-6 h-6 sm:w-5 sm:h-5 text-zinc-500" />
                            <span class="whitespace-nowrap">Follow</span>
                        {/if}
                    </button>
                </DropdownMenu.Item>
                <DropdownMenu.Item>
                    <button class="flex flex-row items-center gap-2 w-full">
                        {#if !$muteList.has(user.pubkey)}
                            <SpeakerX class="w-6 h-6 sm:w-5 sm:h-5 text-red-500" />
                            <span class="whitespace-nowrap text-red-500">Mute</span>
                        {:else}
                            <Plus class="w-6 h-6 sm:w-5 sm:h-5 text-zinc-500" />
                            <span class="whitespace-nowrap">Unmute</span>
                        {/if}
                    </button>
                </DropdownMenu.Item>
            </DropdownMenu.Group>
                <div class="bg-foreground/20 h-[2px] w-full my-1"></div>
                {#each $sortedUserLists as list}
                    <DropdownMenu.Item>
                        <button class="flex flex-row items-center gap-2 w-full">
                            {#if list.items.map(t => t[1]).includes(user.pubkey)}
                                <Check class="w-6 h-6 sm:w-5 sm:h-5 text-green-500" />
                            {:else}
                                <Plus class="w-6 h-6 sm:w-5 sm:h-5 text-zinc-500" />
                            {/if}
                            <span class="whitespace-nowrap">{list.name}</span>
                        </button>
                    </DropdownMenu.Item>
                {/each}
        </DropdownMenu.Content>
    </DropdownMenu.Root>
{/if}

<style lang="postcss">
    li {
        @apply w-full;
    }
</style>