<script lang="ts">
	import FailedPublishesIndicator from "$components/FailedPublishesIndicator.svelte";
	import { openModal } from '$utils/modal';
	import { UserProfileType } from './../../../../app.d.js';
    import OptionsList from "$components/OptionsList.svelte";
	import { Bell, BookmarkSimple, ChalkboardSimple, Fire, Gear, House, PaperPlaneTilt, Plus, CardsThree, Timer, PlusCircle, Tray } from "phosphor-svelte";
	import { NavigationOption } from "../../../../app";
	import NewItemModal from "$modals/NewItemModal.svelte";
    import currentUser, { isGuest } from "$stores/currentUser";
	import CurrentUser from "$components/CurrentUser.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import LogoSmall from '$icons/LogoSmall.svelte';
	import { hasUnreadNotifications, showNotificationOption, unreadNotifications } from '$stores/notifications';
	import SignupModal from '$modals/SignupModal.svelte';
	import { drafts } from '$stores/drafts';

    let hasDrafts = false;

    $: hasDrafts = $drafts.length > 0;

    let options: NavigationOption[];

    $: {
        options = [
            { name: "Home", icon: Fire, href: "/home" },
            { name: "Inbox",  href: "/inbox", icon: Tray },
            { name: "Bookmarks",  href: "/bookmarks", icon: BookmarkSimple },
            { name: "Collections",  href: "/collections", icon: CardsThree },
        ]
        if ($showNotificationOption) {
            options.push(
                { name: "Notifications", icon: Bell, href: "/notifications", badge: $hasUnreadNotifications ? $unreadNotifications?.toString() : undefined }
            );
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
        icon: PlusCircle,
        class: "text-accent2",
        fn: () => openModal(NewItemModal),
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

        {#if hasDrafts && false}
            <OptionsList options={publicationOptions} class="flex-col w-full" collapsed={true} />
            <OptionsList options={[publishOption]} class="flex-col w-full" collapsed={true} />
        {:else}
            <div class="group">
                <OptionsList options={[publishOption]} class="flex-col w-full" collapsed={true} />
                <div class="hidden group-hover:block">
                    <OptionsList options={publicationOptions} class="flex-col w-full" collapsed={true} />
                </div>
            </div>
        {/if}
        
        
    </div>

    <div class="flex flex-col fixed bottom-0 items-center pb-6">
        <FailedPublishesIndicator />
        <div class="group">
        <div class="hidden group-hover:block">
            <OptionsList options={[
                { name: "Settings", icon: Gear, href: "/settings" }
            ]} class="flex-col w-full" collapsed={true} />
        </div>
        
        <OptionsList options={userOptions} class="flex-col w-full" collapsed={true} />
        </div>
    </div>
</div>
