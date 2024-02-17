<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import { debugMode, userActiveSubscriptions, userTiers } from "$stores/session";
	import { Tray, PaperPlane, ChatCircle, House, Funnel, Fire, User, Gear, UserCircle, Bell, Gauge, Bug } from "phosphor-svelte";
    import { Avatar, bunkerNDK, ndk, user } from "@kind0/ui-common";
	import { openModal } from "svelte-modals";
    import NewItemModal from '$modals/NewItemModal.svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { login } from "$utils/login";
	import { hideMobileBottomBar } from '$stores/layout';
	import NavMobileTop from './NavMobileTop.svelte';
	import Item from './Navigation/Item.svelte';
	import CurrentUser from '$components/CurrentUser.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import DashboardIcon from '$icons/DashboardIcon.svelte';
	import { RelayList } from '@nostr-dev-kit/ndk-svelte-components';

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

    let showRelayList = false;
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
            <Item let:active on:click={() => openModal(NewItemModal)} matches={/\/(articles|notes|videos)\/new/}>
                <PaperPlane class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>
        {:else if $user}
            <Item href="/home">
                <PaperPlane class="w-full h-full" weight="fill" />
            </Item>
        {:else if !$user}
            <Item on:click={openSignupModal}>
                <PaperPlane class="w-full h-full" weight="fill" />
            </Item>
        {/if}
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

            <Item href="/dashboard" tooltip="Dashboard" let:active>
                <DashboardIcon class="w-full h-full transition-all duration-300 {active ? "" : "brightness-75 hover:brightness-100"}" />
            </Item>

            <Item href="/home" tooltip="Home" let:active>
                <House class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/" tooltip="Discover" let:active>
                <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <!-- <Item href="/inbox" tooltip="Inbox" let:active>
                <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item> -->

            <!-- <Item href="/highlights" tooltip="Highlights" let:active class="max-sm:hidden">
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} strokeWidth="1.4" />
            </Item> -->

            <Item href="/chat" tooltip="Chat" let:active class="max-sm:hidden">
                <ChatCircle class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>
            {#if $user}
                <Item
                    tooltip="Create something new"
                    let:active on:click={() => openModal(NewItemModal)}
                    matches={/\/(articles|notes|videos)\/new/}
                >
                    <PaperPlane class="w-full h-full" weight={active ? "fill" : "regular"} />
                </Item>
            {:else if !$user}
                <Item on:click={openSignupModal}>
                    <PaperPlane class="w-full h-full" weight="fill" />
                </Item>
            {/if}

            {#if $userActiveSubscriptions.size > 0}
                <div class="flex flex-col transition-all duration-1000 group pt-16 flex-grow overflow-y-auto brightness-90 hover:brightness-100 hover:pt-4">
                    {#each $userActiveSubscriptions.keys() as pubkey}
                        <div class="-mt-16 group-hover:-mt-4 transition-all duration-1000 ">
                            <UserProfile pubkey={pubkey} let:userProfile let:fetching let:authorUrl>
                                <Item href={authorUrl}>
                                    <Avatar {userProfile} {fetching} size="medium" />
                                </Item>
                            </UserProfile>
                        </div>
                    {/each}
                </div>
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
            {#if import.meta.env.VITE_HOSTNAME === "localhost" || $user?.npub === "npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft"}
                <Item on:click={() => $debugMode = !$debugMode} tooltip="Notifications" active={$debugMode}>
                    <Bug class="w-full h-full {$debugMode ? "text-accent2" : "text-inherit"}" weight={$debugMode ? "fill" : "regular"} />
                </Item>

                <Item on:click={() => showRelayList = !showRelayList} tooltip="Relay List" active={showRelayList}>
                    <Gauge class="w-full h-full {showRelayList ? "text-accent2" : "text-inherit"}" weight={showRelayList ? "fill" : "regular"} />
                </Item>

                {#if showRelayList}
                    <div class="fixed top-0 left-20 w-[50vw] bg-base-200/80 backdrop-blur-[50px] h-screen overflow-y-auto pr-6">
                        <RelayList ndk={$ndk} />
                    </div>
                {/if}
            {/if}

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