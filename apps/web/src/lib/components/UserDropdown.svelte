<script lang="ts">
    import { get as getStore } from 'svelte/store';
	import { Avatar, CollapsableDropdown, Name, ndk, user } from '@kind0/ui-common';
    import {SignOut, SquaresFour, Tray} from 'phosphor-svelte';

    export function logout(): void {
        const $ndk = getStore(ndk);
        $ndk.signer = undefined;
        user.set(undefined);
        localStorage.removeItem("currentUserFollowPubkeysStore");
        localStorage.removeItem("currentUserStore");
        localStorage.removeItem("user-follows");
        localStorage.removeItem("network-follows");
        localStorage.removeItem("network-follows-updated-t");
        localStorage.removeItem("currentUserNpub");
        localStorage.removeItem("nostr-target-npub");

        // explicitly prevent auto-login with NIP-07
        localStorage.setItem("nostr-key-method", "none");
    }
</script>

<CollapsableDropdown>
        <div slot="dropdown-btn-open" class="btn-circle avatar">
            <Avatar user={$user}/>
        </div>

        <ul slot="dropdown-content" class="absolute right-0 divide-y divide-neutral-800 menu p-0 z-50 rounded-box whitespace-nowrap text-base">
            <li><a href="#">
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
        </ul>

    </CollapsableDropdown>

    <style lang="postcss">
        li a {
            @apply whitespace-nowrap;
        }
    </style>