<script lang="ts">
	import { openModal } from '$utils/modal';
	import ShareModal from '$modals/ShareModal.svelte';
    import UserProfile from "$components/User/UserProfile.svelte";
	import { NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { DotsThree, Export } from "phosphor-svelte";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import CreatorHeaderFollowButton from "./CreatorHeaderFollowButton.svelte";
	import CreatorHeaderInboxButton from "./CreatorHeaderInboxButton.svelte";
	import CreatorHeaderSupportButton from './CreatorHeaderSupportButton.svelte';
	import { appMobileView } from '$stores/app';
	import { Actions, ActionsButton, ActionsGroup, Button, Navbar, NavbarBackLink, Toolbar } from 'konsta/svelte';
	import Avatar from '$components/User/Avatar.svelte';
	import Name from '$components/User/Name.svelte';
	import { pageHeader } from '$stores/layout';
	import HeaderMobileActionSheet from './HeaderMobileActionSheet.svelte';
	import { userFollows } from '$stores/session';
	import currentUser from '$stores/currentUser';

    export let user: NDKUser;
    let userProfile: NDKUserProfile;
    export let authorUrl: string;
    export let fetching: boolean;
    export let collapsed: boolean = true;
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
        document.addEventListener("touchmove", updateCollapsed);
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
                collapsed = true;
                dispatch("resize");
            } else if (touchStartY - touchEndY < -300) {
                collapsed = false;
                dispatch("resize");
            }
        }
    }

    function touchEnd() {
        touchStartY = undefined;
    }
    
    function updateCollapsed() {
        y = window.scrollY;

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
    <Navbar top title={userProfile?.displayName}>
        <NavbarBackLink slot="left" onClick={() => { window.history.back() }} />

        <div slot="subnavbar" class="flex flex-row items-end gap-0 overflow-y-hidden subnavbar">
            {#if $pageHeader?.subNavbarOptions && $pageHeader?.subNavbarValue}
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
<div class="z-20 w-full {collapsed ? "" : "min-h-[15rem]"}" on:touchstart={() => {if (collapsed) collapsed = false}}>
    <div class="relative h-full w-full">
        {#if userProfile?.banner}
            <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top z-1 transition-all duration-300  {collapsed ? "opacity-20" : "opacity-40"}" alt={userProfile?.name}>
            <div class="absolute w-full h-full bg-gradient-to-b from-transparent to-base-100 z-2"></div>
        {/if}

        <!-- Container -->
        <div class="flex flex-col pt-4 items-center relative z-50  max-sm:pt-0-safe text-foreground {$$props.containerClass??""} {collapsed ? "max-sm:px-2" : ""}">
            <div class="flex {collapsed ? "flex-row" : "flex-col"} items-center justify-start gap-2 w-full transition-all duration-300">
                {#if $appMobileView}
                    <div class="left-2 top-0-safe {collapsed ? "" : "absolute"}">
                        <NavbarBackLink onClick={() => { window.history.back() }} />
                    </div>
                {/if}
                
                <!-- Avatar -->
                <div class="{collapsed ? "w-8 h-8" : "w-32 h-32"} transition-all duration-300">
                    <Avatar user={user} {userProfile} {fetching} class="
                        transition-all duration-300 flex-none object-cover w-full h-full"
                    />
                </div>
                <h1 class="text-foreground font-semibold whitespace-nowrap mb-0 transition-all duration-300 {collapsed ? "text-sm grow" : ""}">
                    <Name {user} {userProfile} {fetching} />
                </h1>
                <div class="text-sm transition-all duration-300 max-sm:text-xs max-sm:px-4 max-sm:text-center" class:hidden={collapsed}>
                    {#if fetching && !userProfile?.about}
                        <div class="skeleton h-15 w-48">&nbsp;</div>
                    {:else if userProfile?.about}
                        {userProfile.about}
                    {:else}
                        &nbsp;
                    {/if}
                </div>

                {#if collapsed}
                    <div>
                        <div class="flex flex-row items-end justify-end gap-4">
                            <CreatorHeaderFollowButton {user} {collapsed} />
                            <CreatorHeaderInboxButton {user} {collapsed} />
                            <CreatorHeaderSupportButton {user} {collapsed} />
                            <button class="flex items-center justify-center gap-1 transition-all duration-300 {collapsed ? "flex-row" : "flex-col"}" on:click={() => openModal(ShareModal, { })}>
                                <Export class="{collapsed ? ("w-6 h-6") : ("w-9 h-9")}" weight="bold" />
                                <span class="max-sm:hidden {collapsed ? "max-sm:hidden text-sm" : "text-base"}">Share</span>
                            </button>
                        </div>
                    </div>
                {/if}
            </div>

            <div class="
                w-full flex pb-2  gap-4 {collapsed ? "mt-2" : "flex-col-reverse mt-4 sm:my-8"}
                {$appMobileView ? "flex-col-reverse justify-center items-center" : "items-center"}
            ">
                <HorizontalOptionsList class="w-fit" {options} on:changed={() => collapsed = true} />
                
                {#if !collapsed}
                    <div class="flex flex-row items-stretch justify-end sm:gap-6 backdrop-blur-xl rounded px-4 py-2 max-sm:w-full max-sm:justify-evenly">
                        <CreatorHeaderFollowButton {user} {collapsed} />
                        <CreatorHeaderInboxButton {user} {collapsed} />
                        <CreatorHeaderSupportButton {user} {collapsed} />
                        <!-- <button class="flex items-center justify-center gap-1 transition-all duration-300 {collapsed ? "flex-row" : "flex-col"}" on:click={() => openModal(ShareModal, { })}>
                            <Export class="{collapsed ? ("w-6 h-6") : ("w-9 h-9")}" weight="bold" />
                            <span class="max-sm:hidden {collapsed ? "max-sm:hidden text-sm" : "text-base"}">Share</span>
                        </button> -->
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>
{/if}
{/key}

<slot />
