<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import { userTiers } from "$stores/session";
	import { Compass, Tray, PaperPlane, ChatCircle, House, Funnel, Fire, User, Gear, UserCircle } from "phosphor-svelte";
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
    sm:w-20 w-full
    max-sm:btm-nav max-sm:btm-nav-lg
    transition-all duration-1000
    z-50
" class:forceHidden={$hideMobileBottomBar}>
    <div class="
        sm:pt-6
        flex max-sm:flex-row sm:flex-col justify-between items-center gap-3 flex-nowrap
        h-full
    ">
        <div class="
            items-center flex flex-nowrap
            sm:flex-col
            justify-between sm:justify-start
            w-full
            gap-4
        ">
            <VerticalNavbarItem tooltip="Signup" on:click={openSignupModal}>
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

            <VerticalNavbarItem href="/highlights" tooltip="Highlights" let:active class="max-sm:hidden">
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/chat" tooltip="Chat" let:active class="max-sm:hidden">
                <ChatCircle class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>
            {#if $user && $userTiers && $userTiers.length > 0}
                <VerticalNavbarItem tooltip="Create something new" let:active on:click={() => openModal(NewItemModal)}>
                    <PaperPlane class="w-full h-full" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>
            {:else if $user}
                <VerticalNavbarItem tooltip="Start publishing on Nostr" href="/welcome/creators">
                    <PaperPlane class="w-full h-full" weight="fill" />
                </VerticalNavbarItem>
            {/if}
        </div>

        <div class="
            max-sm:hidden
            items-center flex flex-nowrap
            sm:flex-col
            justify-between sm:justify-start
            w-full
            gap-4
        ">
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
        @apply max-sm:-bottom-64;
    }
</style>