<script lang="ts">
	import { openModal } from '$utils/modal';
	import { UserProfileType } from './../../../../app.d.js';
	import { layoutNavState } from "$stores/layout";
    import OptionsList from "$components/OptionsList.svelte";
	import { Bell, BookmarkSimple, ChalkboardSimple, Fire, Gear, House, PaperPlaneTilt, Plus, SquaresFour, Timer } from "phosphor-svelte";
	import { NavigationOption } from "../../../../app";
	import NewItemModal from "$modals/NewItemModal.svelte";
    import currentUser, { isGuest } from "$stores/currentUser";
	import CurrentUser from "$components/CurrentUser.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { page } from '$app/stores';
	import Logo from '$icons/Logo.svelte';
	import LogoSmall from '$icons/LogoSmall.svelte';
	import { hasUnreadNotifications, unreadNotifications } from '$stores/notifications';
	import SignupModal from '$modals/SignupModal.svelte';
	import { drafts } from '$stores/drafts';

    let hasDrafts = false;

    $: hasDrafts = $drafts.length > 0;

    let collapsed = false;
    $: collapsed = $layoutNavState === "collapsed";
    
    let layoutNavWidth: string;
    $: layoutNavWidth = collapsed ? "w-navbar-collapsed" : "pl-6";


    let options: NavigationOption[];

    $: {
        options = [
            { name: "Home", icon: House, href: "/home" },
            { name: "Bookmarks",  href: "/bookmarks", icon: BookmarkSimple },
            { name: "Discover",  href: "/discover", icon: Fire },
            { name: "Collections",  href: "/collections", icon: SquaresFour },
        ]
        if ($currentUser && (!$isGuest || $hasUnreadNotifications)) {
            
        } else {
            // remove the option with name notifications
            const index = options.findIndex(option => option.name === "Notifications");
            if (index !== -1) {
                options.splice(index, 1);
            }
        }

        options = options;
    }
    
    let publicationOptions: NavigationOption[] = [];
    let userOptions: NavigationOption[] = [];
    let profile: UserProfileType;
    let authorUrl: string;
    
    $: {
        publicationOptions = [
            { name: "Schedule", icon: Timer, href: "/schedule" },
            { name: "Drafts", icon: ChalkboardSimple, href: "/drafts", badge: hasDrafts ? true : undefined },
        ]
    }

    $: {
        let userName: string | undefined;

        if (!$currentUser) {
            userName = "Sign Up";
        } else if (profile) {
            userName = (profile.display_name as string) || profile?.displayName || profile.name;
        }

        userName ??= "You";

        if (!$currentUser) {
            userOptions = [{ name: userName, icon: CurrentUser, fn: () => openModal(SignupModal) }]
        } else {
            userOptions = [{ name: userName, icon: CurrentUser, href: authorUrl ?? "/" }]
        }
    }

    let publishOption: NavigationOption;
    
    $: publishOption = {
        name: "Publish",
        icon: PaperPlaneTilt,
        fn: () => openModal(NewItemModal),
        class: collapsed ? "" : 'lg:!bg-accent2 lg:!text-white'
    }
</script>

{#if $currentUser}
    <UserProfile bind:userProfile={profile} bind:authorUrl user={$currentUser} />
{/if}

{#if $$props.class?.match(/fixed/)}
    <div class="max-sm:hidden flex-none {layoutNavWidth}"></div>
{/if}

<div class="
    flex flex-col
    sm:top-0
    sm:h-full
    overflow-hidden z-10
    hover:overflow-visible
    flex-none

    max-sm:fixed max-sm:bottom-0 max-sm:left-0 max-sm:right-0
    max-sm:w-full

    {layoutNavWidth}
    {$$props.class??""}
">
    <!-- Mobile view -->
    <div class="btm-nav btm-nav-lg sm:hidden fixed z-[5000000] !bg-black">
        <a href="/home" class:active={$page.url.pathname.startsWith('/home')}>
            <House class="w-navbar-icon h-navbar-icon" />
        </a>
        <a href="/bookmarks" class:active={$page.url.pathname.startsWith('/bookmarks')}>
            <BookmarkSimple class="w-navbar-icon h-navbar-icon" />
        </a>
        <button on:click={() => openModal(NewItemModal, {})}>
            <Plus class="w-navbar-icon h-navbar-icon" weight="duotone" />
        </button>
        <a href="/" class:active={$page.url.pathname === '/'}>
            <Fire class="w-navbar-icon h-navbar-icon" />
        </a>
        {#if $currentUser}
            <a href="/notifications" class:active={$page.url.pathname.startsWith('/notifications')}>
                <div class="indicator">
                    {#if $hasUnreadNotifications}
                        <span class="indicator-item w-2 h-2 bg-accent2"></span>
                    {/if}
                    <Bell class="w-navbar-icon h-navbar-icon" />
                </div>
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
            <Logo class="w-40 hidden {collapsed ? "" : "lg:inline"}" />
            <LogoSmall class="w-10 m-4 {collapsed ? "" : "lg:hidden"}" />
        </div>

        <div class="h-[var(--layout-header-height)] mb-6"></div>
        
        <OptionsList {options} class="flex-col w-full" {collapsed} />

        {#if hasDrafts}
            <OptionsList options={publicationOptions} class="flex-col w-full" {collapsed} />
            <OptionsList options={[publishOption]} class="flex-col w-full" {collapsed} />
        {:else}
            <div class="group">
                <OptionsList options={[publishOption]} class="flex-col w-full" {collapsed} />
                <div class="hidden group-hover:block">
                    <OptionsList options={publicationOptions} class="flex-col w-full" {collapsed} />
                </div>
            </div>
        {/if}
        
        
    </div>

    <div
        class="flex flex-col fixed bottom-0 max-sm:hidden items-center pb-6"
    >
    <div class="group">
        <div class="hidden group-hover:block">
            <OptionsList options={[
                { name: "Settings", icon: Gear, href: "/settings" }
            ]} class="flex-col w-full" {collapsed} />
        </div>
        
        <OptionsList options={userOptions} class="flex-col w-full" {collapsed} />
        </div>
    </div>
</div>
