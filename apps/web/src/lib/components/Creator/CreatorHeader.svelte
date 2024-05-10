<script lang="ts">
	import FollowButton from "$components/buttons/FollowButton.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import currentUser from "$stores/currentUser";
	import { pageHeader } from "$stores/layout";
	import { Avatar, Name } from "@kind0/ui-common";
	import { NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { CaretRight, Star, Ticket } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile;
    export let authorUrl: string;
    export let fetching: boolean;
    export let collapsed: boolean = false;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;

    onMount(() => {
        window.addEventListener('scroll', updateScroll);
    });

    onDestroy(() => {
        window.removeEventListener('scroll', updateScroll);
    });

    let scrollY = 0;

    function updateScroll() {
        scrollY = window.scrollY;
        if (scrollY > 80) {
            collapsed = true;
        } else if (scrollY < 20) {
            collapsed = false;
        }
    }

    $: if (userProfile?.name) {
        $pageHeader = { title: userProfile.name }
    }
</script>

<!-- <div class="relative w-full max-w-screen overflow-hidden max-sm:pb-[20vh] pb-[25%] max-sm:hidden">
    {#if userProfile?.banner}
        <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
    {:else}
        <div class="absolute w-full h-full object-cover object-top lg:rounded bg-gradient-to-b from-base-300 to-transparent via-bg-base-300" />
    {/if}
</div> -->

<div class="
    flex
    max-sm:gap-4
    overflow-clip
    max-sm:py-1
    items-end justify-between p-3 sm:px-6
    gap-4
    transition-all duration-300
    w-full max-sm:w-screen
    max-sm:flex-row max-sm:items-center
">
    <div dir="auto" class="flex items-center sm:items-end shrink gap-4">
        <Avatar user={user} {userProfile} {fetching} class="
            transition-all duration-300 flex-none object-cover
            {collapsed ? 'w-12 h-12 sm:w-14 sm:h-14' : 'w-16 h-16 sm:w-24 sm:h-24'}
        " />

        <div class="overflow-clip">
            <div class="name text-xl font-semibold text-base-100-content truncate shrink basis-0 overflow-clip">
                <Name {user} {userProfile} {fetching} />
            </div>
            <p class="
                text-sm truncate max-w-md text-neutral-500 w-full
                { collapsed ? "max-sm:!hidden" : ""}
            ">
                {#if fetching && !userProfile?.about}
                    <div class="skeleton h-15 w-48">&nbsp;</div>
                {:else if userProfile?.about}
                    {userProfile?.about}
                {:else}
                    &nbsp;
                {/if}
            </p>
        </div>
    </div>

    <div class="flex flex-row items-center gap-2">
        {#if user.pubkey === $currentUser?.pubkey}
            <a
                href="{authorUrl}/backstage"
                class="
                    flex flex-row items-center !gap-0
                    whitespace-nowrap text-base
                    max-sm:px-6
                    lg:py-3 lg:button border-accent2 w-full transition-all duration-300 group
                    border-2 hover:bg-accent2/20 lg:bg-transparent
                    rounded-full p-2
                    !text-white
                "
            >
                <Star size={24} class="inline lg:mr-2" />
                <span class="hidden lg:inline">
                    Backstage
                </span>
            </a>
        {:else if $tiers}
            <SubscribeButton {user} {userProfile} {tiers} buttonClass="
                max-sm:bg-accent2 max-sm:!text-white max-sm:btn max-sm:btn-circle
                max-sm:!px-0
            " />
        {/if}
        <FollowButton {user} />
    </div>
</div>