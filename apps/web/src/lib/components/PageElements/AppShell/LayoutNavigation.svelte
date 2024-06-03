<script lang="ts">
	import FailedPublishesIndicator from "$components/FailedPublishesIndicator.svelte";
	import { openModal } from '$utils/modal';
	import { UserProfileType } from './../../../../app.d.js';
    import OptionsList from "$components/OptionsList.svelte";
	import { Bell, BookmarkSimple, ChalkboardSimple, Fire, Gear, House, PaperPlaneTilt, Plus, CardsThree, Timer, PlusCircle, Tray, MagnifyingGlass, TextAlignLeft, YoutubeLogo } from "phosphor-svelte";
	import { NavigationOption } from "../../../../app";
	import NewItemModal from "$modals/NewItemModal.svelte";
    import currentUser, { isGuest } from "$stores/currentUser";
	import CurrentUser from "$components/CurrentUser.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import LogoSmall from '$icons/LogoSmall.svelte';
	import { hasUnreadNotifications, showNotificationOption, unreadNotifications } from '$stores/notifications';
	import SignupModal from '$modals/SignupModal.svelte';
	import { drafts } from '$stores/drafts';
	import SearchModal from "$modals/SearchModal.svelte";

    let hasDrafts = false;

    $: hasDrafts = $drafts.length > 0;

    let options: NavigationOption[];

    $: {
        options = [
            { name: "Home", icon: House, href: "/home" },
            // { name: "Inbox",  href: "/inbox", icon: Tray },
            { name: "Reads",  href: "/home/reads", icon: TextAlignLeft },
            { name: "Watch",  href: "/home/videos", icon: YoutubeLogo },
            { name: "Collections",  href: "/collections", icon: CardsThree },
            { name: "Search", fn: () => openModal(SearchModal), icon: MagnifyingGlass },
            { name: "Notifications", icon: Bell, href: "/notifications", badge: $hasUnreadNotifications ? $unreadNotifications?.toString() : undefined },
            { name: "Publish", icon: PlusCircle, class: "text-accent", fn: () => openModal(NewItemModal) },
        ]

        options = options;
    }
    
    let userOptions: NavigationOption[] = [];
    let profile: UserProfileType;
    let authorUrl: string;
    
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

        userOptions = [
            { name: "Settings", icon: Gear, href: "/settings" },
            ...userOptions
        ]

        userOptions = [
            { name: "Drafts", icon: PaperPlaneTilt, href: "/drafts", badge: $drafts.length > 0 ? $drafts.length.toString() : undefined },
            { name: "Schedule", icon: Timer, href: "/schedule", },
            ...userOptions
        ]
    }
</script>

{#if $currentUser}
    <UserProfile bind:userProfile={profile} bind:authorUrl user={$currentUser} />
{/if}

{#if $$props.class?.match(/fixed/)}
    <div class="flex-none w-navbar-collapsed"></div>
{/if}

<div class="
    flex flex-col
    sm:top-0
    bg-base-100
    sm:h-full
    overflow-hidden z-10
    hover:overflow-visible
    flex-none
    w-navbar-collapsed
    fixed sm:left-0 border-r border-base-300

    {$$props.class??""}
">
    <div class="
        flex flex-col h-full
    ">
        <div class="h-[var(--layout-header-height)] flex items-center justify-center fixed top-0 z-[99999]">
            <LogoSmall class="w-10 m-4" />
        </div>

        <div class="h-[var(--layout-header-height)] mb-6"></div>
        
        <OptionsList {options} class="flex-col w-full" collapsed={true} />
    </div>

    <div class="flex flex-col fixed bottom-0 items-center pb-6">
        <FailedPublishesIndicator />
        <OptionsList options={userOptions} class="flex-col w-full" collapsed={true} />
    </div>
</div>
