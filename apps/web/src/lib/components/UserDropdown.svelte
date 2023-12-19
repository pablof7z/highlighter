<script lang="ts">
    import { get as getStore } from 'svelte/store';
	import { Avatar, CollapsableDropdown, Name, ndk, user } from '@kind0/ui-common';
    import {SignOut, SquaresFour, Tray} from 'phosphor-svelte';
	import { debugMode, loginState, userActiveSubscriptions, userFollows, userSuperFollows } from '$stores/session';
    import UserProfile from './User/UserProfile.svelte';

    export function logout(): void {
        const $ndk = getStore(ndk);
        $ndk.signer = undefined;
        user.set(undefined);
        loginState.set("logged-out");
        localStorage.removeItem("currentUserFollowPubkeysStore");
        localStorage.removeItem("currentUserStore");
        localStorage.removeItem("user-follows");
        localStorage.removeItem("user-super-follows");
        localStorage.removeItem("network-follows");
        localStorage.removeItem("network-follows-updated-t");
        localStorage.removeItem("currentUserNpub");
        localStorage.removeItem("nostr-target-npub");
        localStorage.removeItem("jwt");

        document.cookie = "jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";


        // explicitly prevent auto-login with NIP-07
        localStorage.setItem("nostr-key-method", "none");
    }
</script>

<UserProfile user={$user} let:userProfile let:fetching>
    <div class="dropdown dropdown-end">
        <!-- svelte-ignore a11y-label-has-associated-control -->
        <label
            tabindex="-1"
            class="btn-circle avatar flex"
            class:animate-pulse={["logging-in", "contacting-remote-signer"].includes($loginState??"")}
        >
            <Avatar user={$user} {userProfile} {fetching} />
        </label>

        <ul class="dropdown-content divide-y divide-neutral-900 menu p-0 z-50 rounded-box whitespace-nowrap text-base">
            <li><a href="/inbox">
                <Tray size={16} class="mr-2"/>
                Inbox
            </a></li>
            <li><a href="/dashboard">
                <SquaresFour size={16} class="mr-2"/>
                Creator Dashboard
            </a></li>
            <li><a href="/dashboard/tiers">
                <SquaresFour size={16} class="mr-2"/>
                Tiers
            </a></li>
            <li><button on:click={logout} class="w-full">
                <SignOut size={16} class="mr-2"/>
                Log Out
            </button></li>
            {#if $debugMode}
                <li>
                    <div class="flex flex-col gap-4 items-start text-sm">
                        <div>Debug Information</div>
                        <p>User follows: {$userFollows.size}</p>
                        <p>User super-follows: {$userSuperFollows.size}</p>
                        <p>Active Subscriptions: {$userActiveSubscriptions.size}</p>
                    </div>
                </li>
            {/if}
        </ul>
    </div>
</UserProfile>

<style lang="postcss">
    li a {
        @apply whitespace-nowrap;
    }
</style>