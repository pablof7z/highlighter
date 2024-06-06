<script lang="ts">
	import { openModal } from '$utils/modal';
    import UserProfile from "$components/User/UserProfile.svelte";
	import Avatar from '$components/User/Avatar.svelte';
import Name from '$components/User/Name.svelte';
import { ndk } from "$stores/ndk.js";
	import { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { Export } from "phosphor-svelte";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { appMobileView } from '$stores/app';
	import { NavbarBackLink } from 'konsta/svelte';
	import CreatorHeaderFollowButton from '$components/Creator/CreatorHeaderFollowButton.svelte';
	import CreatorHeaderSupportButton from '$components/Creator/CreatorHeaderSupportButton.svelte';
	import CreatorHeaderInboxButton from '$components/Creator/CreatorHeaderInboxButton.svelte';

    export let image: string;
    export let options: NavigationOption[] | undefined = undefined;
    
    export let user: NDKUser;
    let userProfile: NDKUserProfile;
    export let fetching: boolean;
    export let collapsed: boolean = false;

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
<UserProfile {user} bind:userProfile bind:fetching />

<div class="sticky top-0 z-40 w-full overflow-clip {collapsed ? "" : "min-h-[15rem]"} {$$props.class??""}" on:touchstart={() => {if (collapsed) collapsed = false}}>
    <div class="h-full w-full relative">
        {#if image}
            <img src={image} class="absolute w-full h-full object-cover object-top z-[1] transition-all duration-300 {collapsed ? "opacity-20" : ""}" alt={userProfile?.name}>
            <div class="absolute w-full h-full bg-gradient-to-b from-transparent to-base-100 z-[2]"></div>
        {/if}

        <!-- Container -->
        <div class="
            flex flex-col pt-4 px-6 items-center justify-center relative z-50  max-sm:pt-0-safe text-foreground {$$props.containerClass??""} {collapsed ? "max-sm:px-2" : ""}
        ">
            <div class="flex {collapsed ? "flex-row" : "flex-col"} items-center justify-start gap-2 w-full transition-all duration-300">
                {#if $appMobileView}
                    <div class="left-2 top-0-safe {collapsed ? "" : "absolute"}">
                        <NavbarBackLink onClick={() => { window.history.back() }} />
                    </div>
                {/if}
                
                <!-- Avatar -->
                {#if $$slots.centerImage}
                    <div class="{collapsed ? "w-8 h-8" : "w-32 h-32"} transition-all duration-300">
                        <slot name="centerImage" />
                    </div>
                {/if}
                <h1 class="
                    text-foreground font-semibold flex whitespace-nowrap mb-0 transition-all duration-300 {collapsed ? "text-xl grow" : "justify-center items-center"}
                ">
                    <slot name="title" />
                </h1>
                {#if $$slots.subtitle}
                    <div class="text-sm transition-all duration-300 max-sm:text-xs max-sm:px-4 max-sm:text-center" class:hidden={collapsed}>
                        <slot name="subtitle" />
                    </div>
                {/if}

                {#if collapsed}
                    <div>
                        <div class="flex flex-row items-end justify-end gap-4">
                            <CreatorHeaderFollowButton {user} {collapsed} />
                            <CreatorHeaderInboxButton {user} {collapsed} />
                            <CreatorHeaderSupportButton {user} {collapsed} />
                            <!-- <button class="flex items-center justify-center gap-1 transition-all duration-300 {collapsed ? "flex-row" : "flex-col"}" on:click={() => openModal(ShareModal, { })}>
                                <Export class="{collapsed ? ("w-6 h-6") : ("w-9 h-9")}" weight="bold" />
                                <span class="max-sm:hidden {collapsed ? "max-sm:hidden text-sm" : "text-base"}">Share</span>
                            </button> -->
                        </div>
                    </div>
                {/if}
            </div>

            <div class="
                w-full flex pb-2 {collapsed ? "mt-2" : "mt-4 sm:mt-8"}
                {$appMobileView ? "flex-col-reverse justify-center items-center gap-4" : "flex-row justify-between "}
            ">
                {#if $$slots.options}
                    <slot name="options" {collapsed} />
                {:else}
                    {#if options}
                        <HorizontalOptionsList {options} on:changed={() => collapsed = true} />
                    {/if}
                {/if}
                
                {#if !collapsed}
                    <div class="flex flex-row items-end justify-end gap-4">
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
{/key}

<slot />
