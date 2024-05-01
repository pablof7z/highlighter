<script lang="ts">
	import { UserProfileType } from './../../../../app.d.ts';
	import { layoutNavState } from "$stores/layout";
    import OptionsList from "$components/OptionsList.svelte";
	import { Bell, BookmarkSimple, Chalkboard, ChalkboardSimple, Fire, Gear, House, PaperPlaneTilt, SquaresFour, Timer } from "phosphor-svelte";
	import { NavigationOption } from "../../../../app";
	import { openModal } from "svelte-modals";
	import NewItemModal from "$modals/NewItemModal.svelte";
    import currentUser from "$stores/currentUser";
	import CurrentUser from "$components/CurrentUser.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { page } from '$app/stores';
	import Logo from '$icons/Logo.svelte';
	import LogoSmall from '$icons/LogoSmall.svelte';

    function toggle() {
        if (collapsed) {
            $layoutNavState = "normal";
        } else {
            $layoutNavState = "collapsed";
        }
    }

    let collapsed = false;
    $: collapsed = $layoutNavState === "collapsed";
    
    let layoutNavWidth: string;
    $: layoutNavWidth = collapsed ? "w-navbar-collapsed" : "pl-6";


    const options: NavigationOption[] = [
        { name: "Home", icon: House, href: "/home" },
        { name: "Bookmarks",  href: "/bookmarks", icon: BookmarkSimple },
        { name: "Discover",  href: "/", icon: Fire },
        { name: "Notifications", icon: Bell, href: "/notifications"},
        { name: "Publish", icon: PaperPlaneTilt, fn: () => openModal(NewItemModal) },
    ]
    
    let bottomOptions: NavigationOption[] = [];
    let profile: UserProfileType;
    let authorUrl: string;
    
    $: {
        let userName: string | undefined;

        if (!$currentUser) {
            userName = "Sign Up";
        } else if (profile) {
            userName = profile.display_name || profile?.displayName || profile.name;
        }

        userName ??= "You";
        
        bottomOptions = [
            { name: "Settings", icon: Gear, href: "/settings" },
            { name: userName, icon: CurrentUser, href: authorUrl ?? '/settings' }
        ]
    }
</script>

{#if $currentUser}
    <UserProfile bind:userProfile={profile} bind:authorUrl user={$currentUser} />
{/if}

<div class="
    flex flex-col
    sm:top-0
    sm:h-full
    overflow-hidden z-[50000]
    hover:overflow-visible
    flex-none

    max-sm:fixed max-sm:bottom-0 max-sm:left-0 max-sm:right-0
    max-sm:w-full

    {layoutNavWidth}
    {$$props.class??""}
">
    <!-- Mobile view -->
    <div class="btm-nav btm-nav-lg sm:hidden fixed z-[500] !bg-black">
        <a href="/home" class:active={$page.url.pathname.startsWith('/home')}>
            <House class="w-navbar-icon h-navbar-icon" />
        </a>
        <a href="/bookmarks" class:active={$page.url.pathname.startsWith('/bookmarks')}>
            <BookmarkSimple class="w-navbar-icon h-navbar-icon" />
        </a>
        <a href="/" class:active={$page.url.pathname === '/'}>
            <Fire class="w-navbar-icon h-navbar-icon" />
        </a>
        {#if $currentUser}
            <a href="/notifications" class:active={$page.url.pathname.startsWith('/notifications')}>
                <Bell class="w-navbar-icon h-navbar-icon" />
            </a>
        {:else}
            <CurrentUser />
        {/if}
    </div>

    <!-- Normal view -->
    
    <div class="
        max-sm:hidden flex flex-col h-full
        sm:pr-6
    ">
        <div class="h-[var(--layout-header-height)] flex items-center justify-center fixed top-0 z-[99999]">
            {#if !collapsed}
                <Logo class="w-40" />
            {:else}
                <LogoSmall class="w-10 m-4" />
            {/if}
        </div>

        <div class="h-[var(--layout-header-height)] mb-6"></div>
        
        <OptionsList {options} class="flex-col w-full" {collapsed} />

        <div class="divider my-0"></div>

        <OptionsList class="flex-col w-full" options={[
            { name: "Schedule", icon: Timer, href: "/schedule" },
            { name: "Drafts", icon: ChalkboardSimple, href: "/drafts" },
        ]} {collapsed} />
    </div>

    <div class="flex flex-col fixed bottom-0 max-sm:hidden items-center pb-6">
        <OptionsList options={bottomOptions} class="flex-col w-full" {collapsed} />
    </div>
</div>