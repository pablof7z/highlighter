<script lang="ts">
	import { page } from "$app/stores";
    import { openModal } from "svelte-modals";
    import NewItemModal from "$modals/NewItemModal.svelte";
	import { Avatar, user } from "@kind0/ui-common";
	import UserProfile from "./User/UserProfile.svelte";
	import SignupModal from "$modals/SignupModal.svelte";
    import { MagnifyingGlass, Compass, PlusCircle, Tray, UserCircle } from "phosphor-svelte";
	import { afterUpdate, onMount } from "svelte";
	import Logo from "$icons/Logo.svelte";

    const newItemRegex = /^\/(articles|notes|videos|)\/new/;

    let pwaInstalled = false;

    function checkIfPWAIsInstalled() {
        pwaInstalled = window.matchMedia('(display-mode: standalone)').matches;
    }

    onMount(checkIfPWAIsInstalled);
    afterUpdate(checkIfPWAIsInstalled);
</script>

<div class="mobile-nav fixed top-0 flex w-screen left-0 items-center gap-3 px-3 py-2.5 sm:hidden flex-row justify-between hidden">
    <Logo />
    <button class="button">
        Install PWA
    </button>
</div>

<div class="
    mobile-nav btm-nav btm-nav-lg backdrop-blur h-mobile-nav-bar left-0 border-t border-base-300 sm:hidden
    pb-2
">
    {#if $user}
        <UserProfile user={$user} let:userProfile let:fetching>
            <label for="mobile-drawer" class="drawer-button">
                <Avatar user={$user} {userProfile} {fetching} class="w-7 h-7 object-cover" />
                <span>You</span>
            </label>
        </UserProfile>
    {:else}
        <button
            on:click={() => openModal(SignupModal)}
        >
            <UserCircle class="w-full h-full" />
        </button>
    {/if}

	<a
		href="/explore"
		class:active={$page.url.pathname.startsWith('/explore')}
    >
        <Compass class="w-full h-full" />
        <span>Explore</span>
	</a>

    <button
        on:click={() => openModal(NewItemModal)}
    >
        <PlusCircle class="w-full h-full text-accent" weight="fill" />
        <span>Publish</span>
    </button>

    <button
        on:click={() => {alert('Search is not implemented yet!')}}
    >
        <MagnifyingGlass class="w-full h-full"/>
        <span>Search</span>
    </button>

    <a
        href="/inbox"
        class:active={$page.url.pathname === '/inbox'}
    >
        <Tray class="w-full h-full" />
        <span>Inbox</span>
    </a>
</div>

<style lang="postcss">
    .btm-nav > a, .btm-nav > button, .btm-nav > label {
        @apply py-2;
    }

    .btm-nav > a > span, .btm-nav > button > span, .btm-nav > label > span{
        @apply btm-nav-label text-xs hidden;
    }
</style>