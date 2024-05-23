<script lang="ts">
	import { openModal } from '$utils/modal';
	import ShareModal from './../../modals/ShareModal.svelte';
    import UserProfile from "$components/User/UserProfile.svelte";
	import { Avatar, Name, ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { Export } from "phosphor-svelte";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import CreatorHeaderFollowButton from "./CreatorHeaderFollowButton.svelte";
	import CreatorHeaderInboxButton from "./CreatorHeaderInboxButton.svelte";
	import CreatorHeaderSupportButton from './CreatorHeaderSupportButton.svelte';
	import { appMobileView } from '$stores/app';
	import { NavbarBackLink } from 'konsta/svelte';

    export let user: NDKUser;
    let userProfile: NDKUserProfile;
    export let authorUrl: string;
    export let fetching: boolean;
    export let collapsed: boolean = false;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let options: NavigationOption[] = [];

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
    
</script>

{#key user.pubkey}
<UserProfile {user} bind:userProfile />

<div class="sticky top-0 z-20 w-full overflow-clip {collapsed ? "" : "min-h-[15rem]"}" on:touchstart={() => {if (collapsed) collapsed = false}}>
    <div class="relative h-full w-full bg-gradient-to-b from-base-300 to-base-100">
        {#if userProfile?.banner}
            <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top z-[1] transition-all duration-300 {collapsed ? "opacity-20" : ""}" alt={userProfile?.name}>
            <div class="absolute w-full h-full bg-gradient-to-b from-transparent to-base-100 z-[2]"></div>
        {/if}

        <!-- Container -->
        <div class="flex flex-col pt-4 items-center relative z-50  max-sm:pt-0-safe text-white {$$props.containerClass??""} {collapsed ? "max-sm:px-2" : ""}">
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
                <h1 class="text-white font-semibold whitespace-nowrap mb-0 transition-all duration-300 {collapsed ? "text-sm grow" : ""}">
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
                                <Export class="" size={$appMobileView ? 25 : 20} weight="bold" />
                                <span class="text-xs max-sm:hidden">Share</span>
                            </button>
                        </div>
                    </div>
                {/if}
            </div>

            <div class="
                w-full flex pb-2 {collapsed ? "mt-2" : "mt-4 sm:mt-8"}
                {$appMobileView ? "flex-col-reverse justify-center items-center gap-4" : "flex-row justify-between "}
            ">
                <HorizontalOptionsList {options} on:changed={() => collapsed = true} />
                
                {#if !collapsed}
                    <div class="flex flex-row items-end justify-end gap-4">
                        <CreatorHeaderFollowButton {user} {collapsed} />
                        <CreatorHeaderInboxButton {user} {collapsed} />
                        <CreatorHeaderSupportButton {user} {collapsed} />
                        <button class="flex items-center justify-center gap-1 transition-all duration-300 {collapsed ? "flex-row" : "flex-col"}" on:click={() => openModal(ShareModal, { })}>
                            <Export class="" size={20} weight="bold" />
                            <span class="text-xs">Share</span>
                        </button>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>
{/key}

<slot />
