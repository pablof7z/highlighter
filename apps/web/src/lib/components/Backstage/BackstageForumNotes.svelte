<script lang="ts">
	import NewGroupPostModal from "$modals/NewGroupPostModal.svelte";
	import currentUser from "$stores/currentUser";
	import { openModal } from "$utils/modal";
	import { Avatar, RelativeTime, ndk } from "@kind0/ui-common";
	import { NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { ArrowRight } from "phosphor-svelte";

    export let user: NDKUser;
    export let authorUrl: string;

    const forumActivity = $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupNote], "#h": [user.pubkey], limit: 20 },
    ]);

    let eosed = false;
    
    forumActivity.onEose(() => eosed = true);
    setTimeout(() => eosed = true, 5000);

    function newPost() {
        openModal(NewGroupPostModal, {
            creator: user,
        })
    }

</script>

<div class="backstage-box-container {$$props.class??""}">
    <div class="title">
        <span class="text-sm">
            Forum Activity
        </span>

        <a href="{authorUrl}/backstage/forum" class="text-sm">
            <ArrowRight class="w-5 h-5" />
        </a>
    </div>

    {#if eosed && $forumActivity.length === 0}
        <div class="text-white text-center">
            No forum activity
        </div>
    {:else}
        <div class="flex flex-col grow overflow-y-auto overflow-x-clip -mx-2">
            {#each $forumActivity.slice(0, 3) as e}
                <a href="{authorUrl}/backstage/forum/${e.encode()}" class="flex flex-row gap-4 hover:bg-white/5 p-2">
                    <Avatar user={e.author} size="small" />
                    <div class="flex flex-col items-start">
                        <div class="text-base truncate">
                            {#if e.tagValue("title")}
                                <span class="text-white font-medium">
                                    {e.tagValue("title")}
                                </span>
                            {:else}
                                <span class="text-sm">
                                    {e.content.slice(0, 100)}
                                </span>
                            {/if}
                        </div>
                        <div class="text-xs">
                            <RelativeTime event={e} />
                        </div>
                    </div>
                </a>
            {/each}
        </div>
    {/if}

    {#if user.pubkey === $currentUser?.pubkey}
        <div class="text-white">
            <button class="button" on:click={newPost}>
                Create New Post
            </button>
        </div>
    {/if}
</div>