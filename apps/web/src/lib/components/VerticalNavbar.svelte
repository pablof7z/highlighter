<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import { userTiers } from "$stores/session";
	import { Tray, PaperPlane, ChatCircle, House, Funnel, Fire, User, Gear, UserCircle, Bell } from "phosphor-svelte";
    import { bunkerNDK, ndk, user } from "@kind0/ui-common";
	import { openModal } from "svelte-modals";
	import CurrentUser from "./CurrentUser.svelte";
	import VerticalNavbarItem from "./VerticalNavbarItem.svelte";
    import NewItemModal from '$modals/NewItemModal.svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { login } from "$utils/login";
	import { hideMobileBottomBar } from '$stores/layout';

    async function openSignupModal() {
        if (window.nostr) {
            const u = await login($ndk, $bunkerNDK, 'nip07');
            if (u) {
                $user = u;
                return;
            }
        }

        openModal(SignupModal);
    }
</script>

<div class="
    justify-between items-stretch inline-flex fixed border-r border-base-300 flex-col h-full mobile-nav !bg-base-100 mobile-nav
    md:w-20 w-full
    max-md:btm-nav max-md:btm-nav-lg
    z-50
" class:forceHidden={$hideMobileBottomBar}>
    <div class="
        lg:pt-6
        flex max-md:flex-row md:flex-col justify-between items-center gap-3 flex-nowrap
        h-full
    ">
        <div class="
            items-center flex flex-nowrap
            md:flex-col
            justify-between md:justify-start
            w-full
            lg:gap-2
            max-sm:hidden
        ">
            <VerticalNavbarItem tooltip="Signup" class="p-0" elClass="p-0">
                <CurrentUser>
                    <UserCircle class="w-full h-full" />
                </CurrentUser>
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/home" tooltip="Home" let:active>
                <House class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/explore" tooltip="Explore" let:active>
                <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/inbox" tooltip="Inbox" let:active>
                <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/highlights" tooltip="Highlights" let:active class="max-md:hidden">
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/chat" tooltip="Chat" let:active class="max-sm:hidden">
                <ChatCircle class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>
            {#if $user && $userTiers && $userTiers.length > 0}
                <VerticalNavbarItem tooltip="Create something new" let:active on:click={() => openModal(NewItemModal)}>
                    <PaperPlane class="w-full h-full text-white" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>
            {:else if $user}
                <VerticalNavbarItem tooltip="Start publishing on Nostr" href="/welcome/creators">
                    <PaperPlane class="w-full h-full text-white" weight="fill" />
                </VerticalNavbarItem>
            {/if}
        </div>
        <div class="
            items-center flex flex-nowrap
            md:flex-col
            justify-between md:justify-start
            w-full
            lg:gap-3
            sm:hidden
        ">
            <!-- Left side -->
            <div class="flex flex-row justify-between flex-grow w-full">
                <VerticalNavbarItem tooltip="Signup" on:click={openSignupModal} class="p-0" elClass="p-0">
                    <CurrentUser>
                        <UserCircle class="w-full h-full" />
                    </CurrentUser>
                </VerticalNavbarItem>

                <VerticalNavbarItem href="/home" tooltip="Home" let:active>
                    <House class="w-full h-full" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>

                <VerticalNavbarItem href="/explore" tooltip="Explore" let:active>
                    <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>
            </div>

            <!-- Center -->
            <div class="flex flex-row w-48">
                {#if $user && $userTiers && $userTiers.length > 0}
                    <VerticalNavbarItem tooltip="Create something new" let:active on:click={() => openModal(NewItemModal)}>
                        <PaperPlane class="w-full h-full text-white" weight={active ? "fill" : "regular"} />
                    </VerticalNavbarItem>
                {:else if $user}
                    <VerticalNavbarItem tooltip="Start publishing on Nostr" href="/welcome/creators">
                        <PaperPlane class="w-full h-full text-white" weight="fill" />
                    </VerticalNavbarItem>
                {/if}
            </div>

            <!-- Right side -->
            <div class="flex flex-row justify-between flex-grow w-full">
                <VerticalNavbarItem href="/inbox" tooltip="Inbox" let:active>
                    <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>

                <VerticalNavbarItem href="/highlights" tooltip="Highlights" let:active>
                    <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>

                <VerticalNavbarItem tooltip="Notifications" href="/notifications">
                    <Bell class="w-full h-full" />
                </VerticalNavbarItem>
            </div>
        </div>

        <div class="
            max-md:hidden
            items-center flex flex-nowrap
            md:flex-col
            justify-between md:justify-start
            w-full
            gap-4
        ">
            <VerticalNavbarItem tooltip="Notifications" href="/notifications">
                <Bell class="w-full h-full" />
            </VerticalNavbarItem>
            <VerticalNavbarItem tooltip="Settings" href="/settings">
                <Gear class="w-full h-full" />
            </VerticalNavbarItem>
        </div>
    </div>
</div>

<style>
    .btm-nav > a, .btm-nav > button, .btm-nav > label {
        @apply py-2;
    }

    .btm-nav > a > span, .btm-nav > button > span, .btm-nav > label > span{
        @apply btm-nav-label text-xs hidden;
    }

    .forceHidden {
        @apply max-md:-bottom-64;
    }
</style>