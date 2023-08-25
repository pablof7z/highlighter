<script lang="ts">
    import CollapsableDropdown from '$lib/components/CollapsableDropdown.svelte';
    import Avatar from './Avatar.svelte';
    import { currentUser } from '$stores/current-user';
    import ndk from '$lib/stores/ndk';
    import GearIcon from '$lib/icons/Gear.svelte';
    import Notification from './Notification.svelte';
    import { Name } from '@nostr-dev-kit/ndk-svelte-components';
    import SubtleButton from './buttons/SubtleButton.svelte';
    import { get as getStore } from 'svelte/store';

    export function logout(): void {
        const $ndk = getStore(ndk);
        $ndk.signer = undefined;
        currentUser.set(undefined);
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
        <div slot="dropdown-button" class="btn-circle avatar hover:border hover:border-accent2">
            <Avatar ndk={$ndk} user={$currentUser}/>
        </div>

        <ul class="divide-y divide-neutral-800 menu p-0 w-[245px] rounded-box">
            <div>
                <div class="flex justify-between items-center menu-title px-[22px] py-[19px] gap-2">
                    <div class="w-0 flex flex-grow flex-row items-center gap-4">
                        <Avatar
                            ndk={$ndk}
                            user={$currentUser}
                            class="
                                w-8 h-8 border-2 border-base-300 rounded-full
                            "
                        />
                        <div class="text-center text-base text-base-100-content font-medium truncate">
                            <Name
                                ndk={$ndk}
                                user={$currentUser}
                                class="
                                "
                            />
                        </div>
                    </div>
                    <GearIcon />
                </div>
            </div>
            <div class="py-4 px-5 hidden">
                <span class="text-[10px] font-semibold tracking-widest">
                    NOTIFICATIONS
                </span>
                <div class="flex flex-row py-3 justify-between">
                    <!-- TODO UPDATE FUNCTIONAL NOTIFICATIONS COMPONENT -->
                    <Notification title={"Zaps"} notifications={6} />
                    <Notification title={"Likes"} />
                    <Notification title={"Comments"} />
                    <Notification title={"Unknown"} />
                </div>
            </div>
            <div class="p-[22px]">
                <SubtleButton handleClick={logout} class="w-full">
                    <span slot="btn-content">Log Out</span>
                </SubtleButton>
            </div>
        </ul>

    </CollapsableDropdown>