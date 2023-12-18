<script lang="ts">
	import { page } from "$app/stores";
    import { openModal } from "svelte-modals";
    import NewItemModal from "$modals/NewItemModal.svelte";
	import { debugMode } from "$stores/session";
	import { Avatar, user } from "@kind0/ui-common";
	import { Bug, Compass, House, MagnifyingGlass, PlusCircle, Tray, UserCircle } from "phosphor-svelte";
	import UserProfile from "./User/UserProfile.svelte";
	import Signup from "$modals/Signup.svelte";

    const newItemRegex = /^\/(articles|notes|videos|)\/new/;
</script>

<div class="btm-nav btm-nav-md left-0 border-t border-base-300 sm:hidden">
    {#if $user}
        <UserProfile user={$user} let:userProfile let:fetching>
            <label for="mobile-drawer" class="drawer-button">
                <Avatar user={$user} {userProfile} {fetching} class="w-7 h-7 object-cover" />
                <span>You</span>
            </label>
        </UserProfile>
    {:else}
        <button
            on:click={() => openModal(Signup)}
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
        <PlusCircle class="w-full h-full" />
        <span>Publish</span>
    </button>

    <button
        on:click={() => alert('coming soon')}
    >
        <MagnifyingGlass class="w-full h-full" />
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
    .btm-nav {
        @apply bg-base-200;
    }

    .btm-nav > a, .btm-nav > button, .btm-nav > label {
        @apply p-4;
    }

    .btm-nav > a > span, .btm-nav > button > span, .btm-nav > label > span{
        @apply btm-nav-label text-xs hidden;
    }
</style>