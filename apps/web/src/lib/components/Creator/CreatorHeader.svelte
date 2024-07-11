<script lang="ts">
	import { openModal } from '$utils/modal';
    import UserProfile from "$components/User/UserProfile.svelte";
	import { NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { DotsThree, Export } from "phosphor-svelte";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { appMobileView } from '$stores/app';
	import { Button, Navbar, NavbarBackLink } from 'konsta/svelte';
	import Avatar from '$components/User/Avatar.svelte';
	import Name from '$components/User/Name.svelte';
	import { pageHeader } from '$stores/layout';
	import HeaderMobileActionSheet from './HeaderMobileActionSheet.svelte';
	import { userFollows } from '$stores/session';
	import currentUser from '$stores/currentUser';
	import Npub from '$components/User/Npub.svelte';
	import { inview } from 'svelte-inview';
	import BackButton from "$components/App/Navigation/BackButton.svelte";

    export let user: NDKUser;
    let userProfile: NDKUserProfile;
    export let fetching: boolean;
    export let collapsed: boolean = false;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let options: NavigationOption[] = [];

    let following: boolean;
    $: following = $userFollows.has(user.pubkey);

    const dispatch = createEventDispatcher();

    let y: number = 0;

    onMount(() => {
        document.addEventListener("scroll", updateCollapsed, { passive: true });
        document.addEventListener("touchstart", touchStart);
        document.addEventListener("touchmove", touchMove);
        document.addEventListener("touchend", touchEnd);
        document.addEventListener("resize", updateCollapsed, { passive: true });
    })

    onDestroy(() => {
        document.removeEventListener("scroll", updateCollapsed);
        // document.addEventListener("touchmove", updateCollapsed);
        document.removeEventListener("resize", updateCollapsed);
    })

    let touchStartY: number | undefined;
    
    function touchStart(e) {
        touchStartY = e.touches[0].clientY;
    }

    function touchMove(e) {
        if (touchStartY) {
            let touchEndY = e.touches[0].clientY;
            if (touchStartY - touchEndY > 0) {
                // collapsed = true;
                dispatch("resize");
            } else if (touchStartY - touchEndY < -300) {
                // collapsed = false;
                dispatch("resize");
            }
        }
    }

    function touchEnd() {
        touchStartY = undefined;
    }
    
    function updateCollapsed() {
        y = window.scrollY;

        if (collapsed) {
            window.removeEventListener("scroll", updateCollapsed);
            window.removeEventListener("resize", updateCollapsed);
            return;
        }

        if (y > 100 && !collapsed) {
            collapsed = true;
            dispatch("resize");
        } else if (y < 20 && collapsed) {
            collapsed = false;
            dispatch("resize");
        }
    }

    let actionsOneOpened = false;
</script>

{#key user.pubkey}
<UserProfile {user} bind:userProfile />

{#if collapsed && $appMobileView}
    <div class="" use:inview on:inview_enter={() => collapsed = false} on:inview_leave={() => collapsed = true}></div>
    <Navbar top title={userProfile?.displayName}>
        <BackButton slot="left" />

        <div slot="subnavbar">
            {#if $pageHeader?.subNavbarOptions}
                <HorizontalOptionsList
                    options={$pageHeader.subNavbarOptions}
                    bind:value={$pageHeader.subNavbarValue}
                    class="py-2"
                />
            {/if}
        </div>

        <div slot="right" class="flex flex-row items-center gap-2">
            {#if $currentUser?.pubkey !== user.pubkey}
                {#if !following}
                    <Button outline class="!text-foreground !border-accent">
                        Follow
                    </Button>
                {/if}
                <Button outline rounded raised inline color="" class="flex-none !border-accent" onClick={() => actionsOneOpened = true}>
                    <DotsThree />
                </Button>
            {/if}
        </div>
    </Navbar>

    <HeaderMobileActionSheet bind:opened={actionsOneOpened} bind:following {user} />
{:else}
<div class="z-20 w-full {collapsed ? "" : "sm:min-h-[15rem]"}" use:inview on:inview_enter={() => collapsed = false} on:inview_leave={() => collapsed = true}>
    <div class="relative max-sm:h-[7rem] h-full w-full border">
        {#if $appMobileView}
            <div class="z-50 left-2 top-2-safe {collapsed ? "" : "absolute"}">
                <BackButton />
            </div>
        {/if}
        {#if userProfile?.banner}
            <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top z-1 transition-all duration-300  {collapsed ? "opacity-20" : ""}" alt={userProfile?.name}>
        {/if}
    </div>

    <div class="flex flex-row items-end w-full -mt-12 z-10 relative px-4">
        <div class="flex flex-row items-end grow gap-4">
            <Avatar ring user={user} {userProfile} {fetching} class="
                transition-all duration-300 flex-none object-cover w-24 h-24
                "
            />

            <div class="flex flex-col gap-0">
                <Name {user} {userProfile} {fetching} class="text-foreground font-bold whitespace-nowrap mb-0 transition-all duration-300 {collapsed ? "text-sm grow" : "text-xl"}" />
                <Npub {user} />
            </div>
        </div>

        <div class="flex-none">

        </div>
    </div>

    <div class="border-y border-border py-4 mt-4">
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

</div>
{/if}
{/key}

<slot />
