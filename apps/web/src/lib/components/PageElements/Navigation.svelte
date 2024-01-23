<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import { userTiers } from "$stores/session";
	import { Tray, PaperPlane, ChatCircle, House, Funnel, Fire, User, Gear, UserCircle, Bell } from "phosphor-svelte";
    import { bunkerNDK, ndk, user } from "@kind0/ui-common";
	import { openModal } from "svelte-modals";
    import NewItemModal from '$modals/NewItemModal.svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { login } from "$utils/login";
	import { hideMobileBottomBar } from '$stores/layout';
	import NavMobileTop from './NavMobileTop.svelte';
	import Item from './Navigation/Item.svelte';
	import CurrentUser from '$components/CurrentUser.svelte';

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

<!-- Mobile navigation -->
<div class="sm:hidden">
    <NavMobileTop />

    <!-- Navigation Bottom -->
    <div
        class="btm-nav bg-base-200 bg-opacity-80 mobile-nav z-50"
        class:forceHidden={$hideMobileBottomBar}
    >
        <Item href="/home" let:active>
            <House class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>

        <Item href="/" let:active>
            <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>

        {#if $user && $userTiers && $userTiers.length > 0}
            <Item let:active on:click={() => openModal(NewItemModal)}>
                <PaperPlane class="w-full h-full text-white" weight={active ? "fill" : "regular"} />
            </Item>
        {:else if $user}
            <Item href="/welcome/creators">
                <PaperPlane class="w-full h-full text-white" weight="fill" />
            </Item>
        {:else if !$user}
            <Item on:click={openSignupModal}>
                <PaperPlane class="w-full h-full text-white" weight="fill" />
            </Item>
        {/if}

        <Item href="/inbox" let:active>
            <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>

        <Item href="/highlights" let:active>
            <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} strokeWidth="1.4" />
        </Item>
    </div>
</div>

<div class="
    justify-between items-stretch inline-flex fixed border-r border-base-300 flex-col h-full mobile-nav !bg-base-100 mobile-nav
    sm:w-20 w-full
    max-sm:btm-nav max-sm:btm-nav-lg
    z-50
    max-sm:hidden
">
    <div class="
        lg:pt-3
        flex max-sm:flex-row sm:flex-col justify-between items-center gap-3 flex-nowrap
        h-full
    ">
        <div class="
            items-center flex flex-nowrap
            sm:flex-col
            justify-between sm:justify-start
            w-full
            lg:gap-2
            max-sm:hidden
        ">
            <Item class="p-0" elClass="p-0">
                <CurrentUser>
                    <button on:click={openSignupModal} class="w-full h-full">
                        <UserCircle class="w-full h-full" />
                    </button>
                </CurrentUser>
            </Item>

            <Item href="/home" tooltip="Home" let:active>
                <House class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/" tooltip="Explore" let:active>
                <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/inbox" tooltip="Inbox" let:active>
                <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/highlights" tooltip="Highlights" let:active class="max-sm:hidden">
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} strokeWidth="1.4" />
            </Item>

            <Item href="/chat" tooltip="Chat" let:active class="max-sm:hidden">
                <ChatCircle class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>
            {#if $user && $userTiers && $userTiers.length > 0}
                <Item tooltip="Create something new" let:active on:click={() => openModal(NewItemModal)}>
                    <PaperPlane class="w-full h-full text-white" weight={active ? "fill" : "regular"} />
                </Item>
            {:else if $user}
                <Item tooltip="Start publishing on Nostr" href="/welcome/creators">
                    <PaperPlane class="w-full h-full text-white" weight="fill" />
                </Item>
            {:else if !$user}
                <Item on:click={openSignupModal}>
                    <PaperPlane class="w-full h-full text-white" weight="fill" />
                </Item>
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
            <Item tooltip="Notifications" href="/notifications">
                <Bell class="w-full h-full" />
            </Item>
            <Item tooltip="Settings" href="/settings">
                <Gear class="w-full h-full" />
            </Item>
        </div>
    </div>
</div>

<style lang="postcss">
    .forceHidden {
        @apply max-lg:hidden;
    }
</style>