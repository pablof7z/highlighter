<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
    import { userProfile } from "$stores/session";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { userSubscription, getReceipts, getSortedSupporters, getUserSupporters } from "$stores/user-view";
	import { Avatar, Name, user as currentUser } from "@kind0/ui-common";
	import type { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { closeModal } from "svelte-modals";

    export let user: NDKUser;
    let authorUrl: string;

    function seeContentClicked() {
        closeModal();
        if ($page.url.pathname === authorUrl) {
            window.location.reload();
            return;
        } else {
            goto(authorUrl, { invalidateAll: true });
        }
    }

    const supporters = getSortedSupporters();

    let position: number | undefined;

    $: if ($supporters.includes($currentUser.pubkey)) {
        position = $supporters.indexOf($currentUser.pubkey) + 1;
    }
</script>

<UserProfile {user} let:userProfile={creatorProfile} bind:authorUrl let:fetching>
    <div class="flex flex-col items-center gap-6 p-6">
        <div class="flex flex-row items-start gap-8">
            <div
                class="flex flex-col relative items-center"
                class:hidden={position === undefined}
            >
                <div
                    class="flex flex-col gap-0 items-center justify-center bg-gradient w-32 h-32 flex-none mask mask-squircle"
                >
                    <div class="text-6xl font-black text-white opacity-80">
                        <span class="opacity-40">#</span>{position}
                    </div>
                    <div class="text-sm text-white/80">
                        Supporter
                    </div>
                </div>
                <Avatar userProfile={$userProfile} class="w-10 h-10 absolute bottom-0 -mb-5" type="circle" />
            </div>

            <div class="flex flex-col gap-2">
                <h1 class="text-white text-7xl font-black">Hooray!</h1>
                    {#if position !== undefined}
                        <h1 class="text-2xl text-neutral-500 font-medium grow opacity-50">
                            You've become
                            <Name userProfile={creatorProfile} {fetching} />'s
                            supporter #{position}!
                        </h1>
                    {:else}
                        <h1 class="text-2xl text-neutral-500 font-medium grow opacity-50">
                            You're now supporting
                            <Name userProfile={creatorProfile} {fetching} />'s
                            work!
                        </h1>
                    {/if}
            </div>


        </div>

        <button on:click={seeContentClicked} class="button w-full place-self-end">
            Go backstage
        </button>
    </div>
</UserProfile>