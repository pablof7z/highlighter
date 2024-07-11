<script lang="ts">
	import { NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { DotsThree, Export } from "phosphor-svelte";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { appMobileView } from '$stores/app';
	import Avatar from '$components/User/Avatar.svelte';
	import Name from '$components/User/Name.svelte';
	import { layout, pageHeader } from '$stores/layout';
	import { userFollows } from '$stores/session';
	import currentUser from '$stores/currentUser';
	import Npub from '$components/User/Npub.svelte';
	import { inview } from 'svelte-inview';
	import BackButton from '$components/PageElements/Navigation/BackButton.svelte';
	import FollowButton from "$components/buttons/FollowButton.svelte";
	import { Button } from "$components/ui/button";
	import { openModal } from "$utils/modal";
	import NewGroupModal from "$modals/NewGroupModal.svelte";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let fetching: boolean;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let options: NavigationOption[] = [];

    let following: boolean;
    $: following = $userFollows.has(user.pubkey);

    function inviewchange(e) {
        const { inView } = e.detail;

        if (inView) {
            $layout.header = false;
            $layout.navigation = false;
        } else if (inView === false) {
            $layout.navigation = options;
        }
    }

    onMount(() => {
        $layout.navigation = false;
    })

    $layout.navigation = false;
</script>

<div class="z-20 w-full sm:min-h-[15rem] flex flex-col" use:inview on:inview_change={inviewchange}>
    <div class="max-sm:h-[7rem] w-full h-32 relative z-0">
        {#if $appMobileView}
            <div class="z-50 left-2 top-2-safe absolute">
                <BackButton />
            </div>
        {/if}
        {#if userProfile?.banner}
            <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top z-1 transition-all duration-300" alt={userProfile?.name}>
        {/if}
    </div>

    <div class="flex flex-row items-end w-full px-4 -mt-14 z-1 relative py-[var(--section-vertical-padding)]">
        <div class="flex flex-row items-end grow gap-4">
            <Avatar user={user} {userProfile} {fetching} class="
                transition-all duration-300 flex-none object-cover w-24 h-24
            "/>

            <div class="flex flex-col gap-0">
                <Name {user} {userProfile} {fetching} class="text-foreground font-bold whitespace-nowrap mb-0 transition-all duration-300 text-xl max-h" />
                <Npub {user} />
            </div>
        </div>

        <div class="flex-none">
            {#if user.pubkey !== $currentUser?.pubkey}
                {#if $tiers && $tiers.length > 0}
                {:else}
                    <FollowButton {user} />
                {/if}
            {:else}
                <Button variant="accent" on:click={() => openModal(NewGroupModal)}>
                    Setup creator profile
                </Button>
            {/if}
        </div>
    </div>

    <div class="border-y border-border py-[var(--section-vertical-padding)]">
        <div class="responsive-padding">
            {#if fetching && !userProfile?.about}
                <div class="skeleton h-15 w-48">&nbsp;</div>
            {:else if userProfile?.about}
                {userProfile.about}
            {:else}
                &nbsp;
            {/if}
        </div>
    </div>

    <HorizontalOptionsList {options} class="py-[var(--section-vertical-padding)] border-y border-border" />
</div>

