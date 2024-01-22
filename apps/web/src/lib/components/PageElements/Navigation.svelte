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
    <div class="btm-nav bg-base-200 bg-opacity-80 mobile-nav z-50">
        <Item href="/home" tooltip="Home" let:active>
            <House class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>

        <Item href="/explore" tooltip="Explore" let:active>
            <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>

        {#if $user && $userTiers && $userTiers.length > 0}
            <Item tooltip="Create something new" let:active on:click={() => openModal(NewItemModal)}>
                <PaperPlane class="w-full h-full text-white" weight={active ? "fill" : "regular"} />
            </Item>
        {:else if $user}
            <Item tooltip="Start publishing on Nostr" href="/welcome/creators">
                <PaperPlane class="w-full h-full text-white" weight="fill" />
            </Item>
        {/if}

        <Item href="/inbox" tooltip="Inbox" let:active>
            <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>

        <Item href="/highlights" tooltip="Highlights" let:active>
            <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} />
        </Item>
    </div>
</div>

<div class="
    justify-between items-stretch inline-flex fixed border-r border-base-300 flex-col h-full mobile-nav !bg-base-100 mobile-nav
    md:w-20 w-full
    max-md:btm-nav max-md:btm-nav-lg
    z-50
    max-sm:hidden
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
            <Item tooltip="Signup" class="p-0" elClass="p-0">
                <CurrentUser>
                    <UserCircle class="w-full h-full" />
                </CurrentUser>
            </Item>

            <Item href="/home" tooltip="Home" let:active>
                <House class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/explore" tooltip="Explore" let:active>
                <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/inbox" tooltip="Inbox" let:active>
                <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/highlights" tooltip="Highlights" let:active class="max-md:hidden">
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} />
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
            {/if}
        </div>


        <div class="
            max-md:hidden
            items-center flex flex-nowrap
            md:flex-col
            justify-between md:justify-start
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

