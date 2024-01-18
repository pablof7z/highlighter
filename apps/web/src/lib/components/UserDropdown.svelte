<script lang="ts">
	import { MagnifyingGlass } from 'phosphor-svelte';
	import { Avatar, CollapsableDropdown, Name, ndk, user } from '@kind0/ui-common';
    import {Plus, PlusCircle, SignOut, SquaresFour, Tray} from 'phosphor-svelte';
	import { debugMode, loginState, userActiveSubscriptions, userFollows, userSuperFollows, userAppHandlers } from '$stores/session';
    import UserProfile from './User/UserProfile.svelte';
	import { logout } from '$utils/login';
	import { openModal } from 'svelte-modals';
    import NewItemModal from '$modals/NewItemModal.svelte';
    import { userTiers } from '$stores/session';
</script>

<UserProfile user={$user} let:userProfile let:fetching>
    <div class="dropdown max-sm:dropdown-top">
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
            <li><button on:click={() => openModal(NewItemModal)} class="w-full">
                <PlusCircle size={16} class="mr-2"/>
                Publish
            </button></li>
            {#if $userTiers.length > 0}
                <li><a href="/dashboard">
                    <SquaresFour size={16} class="mr-2"/>
                    Creator Dashboard
                </a></li>
            {:else}
                <li><a href="/dashboard/tiers">
                    <Plus size={16} class="mr-2"/>
                    Set up Creator account
                </a></li>
            {/if}
            <li><a href="/search">
                <MagnifyingGlass size={16} class="mr-2"/>
                Search
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
                        <p>App handlers: {$userAppHandlers.size}</p>
                        <p>
                            {#each $userAppHandlers.entries() as appHandler}
                                {JSON.stringify(appHandler)}
                            {/each}
                        </p>
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