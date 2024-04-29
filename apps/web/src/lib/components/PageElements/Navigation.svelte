<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import { userActiveSubscriptions, userTiers } from "$stores/session";
	import { Tray, PaperPlane, ChatCircle, House, Funnel, Fire, User, Gear, UserCircle, Bell, Gauge, Bug } from "phosphor-svelte";
    import { Avatar, bunkerNDK, ndk, user } from "@kind0/ui-common";
	import { openModal } from "svelte-modals";
    import NewItemModal from '$modals/NewItemModal.svelte';
	import { login } from "$utils/login";
	import NavMobileTop from './NavMobileTop.svelte';
	import Item from './Navigation/Item.svelte';
	import CurrentUser from '$components/CurrentUser.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import DashboardIcon from '$icons/DashboardIcon.svelte';
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

        {#if $user}
            <Item href="/home/for-you" let:active>
                <Bell class="w-full h-full" weight={active ? "fill" : "regular"} />
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

            <Item href="/dashboard" let:active>
                <DashboardIcon class="w-full h-full transition-all duration-300 {active ? "" : "brightness-75 hover:brightness-100"}" />
            </Item>

            <Item href="/home" let:active>
                <House class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <Item href="/" let:active>
                <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item>

            <!-- <Item href="/inbox" tooltip="Inbox" let:active>
                <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item> -->

            <!-- <Item href="/highlights" tooltip="Highlights" let:active class="max-sm:hidden">
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} strokeWidth="1.4" />
            </Item> -->

            <!-- <Item href="/chat" tooltip="Chat" let:active class="max-sm:hidden">
                <ChatCircle class="w-full h-full" weight={active ? "fill" : "regular"} />
            </Item> -->
            {#if $user}
                <Item
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
                <div class="flex flex-col transition-all duration-1000 group pt-16 flex-grow brightness-90 hover:brightness-100 hover:pt-4">
                    {#each $userActiveSubscriptions.keys() as pubkey}
                        <div class="-mt-16 group-hover:-mt-4 transition-all duration-1000 ">
                            <UserProfile pubkey={pubkey} let:userProfile let:fetching let:authorUrl>
                                <Item href={authorUrl}>
                                    <Avatar {userProfile} {fetching} class="flex-none" />
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