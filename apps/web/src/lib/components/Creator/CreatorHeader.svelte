<script lang="ts">
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import { Avatar, Name } from "@kind0/ui-common";
	import { NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile;
    export let fetching: boolean;
    export let collapsed: boolean = false;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;

    onMount(() => {
        window.addEventListener('scroll', updateScroll);
    });

    onDestroy(() => {
        window.removeEventListener('scroll', updateScroll);
    });

    let scrollY = 0;

    function updateScroll() {
        scrollY = window.scrollY;
        if (scrollY > 80) {
            collapsed = true;
        } else {
            collapsed = false;
        }
    }
</script>

<div class="
    flex
    max-sm:gap-4
    overflow-clip
    items-end justify-between p-3 sm:px-6 sm:py-4 sm:-mt-16
    gap-4
    transition-all duration-300
    w-full max-sm:w-screen
    sticky top-0 z-[50]
    { !collapsed ?
        "bg-transparent" :
        "bg-black/90"
    }
    max-sm:flex-row max-sm:items-center
">
    <div class="flex items-center sm:items-end shrink">
        <Avatar user={user} {userProfile} {fetching} size={collapsed ? "small" : "medium"} class="
            transition-all duration-300 flex-none object-cover
            {collapsed ? 'w-14 h-14' : 'w-16 h-16 sm:w-28 sm:h-28'}
        " />

        <div class="ml-4 overflow-clip">
            <div class="name text-xl font-semibold text-base-100-content truncate shrink basis-0 overflow-clip">
                <Name {userProfile} {fetching} />
            </div>
            <p class="
                text-sm truncate max-w-md text-neutral-500 w-full
                { collapsed ? "max-sm:!hidden" : ""}
            ">
                {#if fetching && !userProfile?.about}
                    <div class="skeleton h-15 w-48">&nbsp;</div>
                {:else if userProfile?.about}
                    {userProfile?.about}
                {:else}
                    &nbsp;
                {/if}
            </p>
        </div>
    </div>

    {#if $tiers}
        <SubscribeButton {user} {userProfile} {tiers} buttonClass="
            max-sm:bg-accent2 max-sm:text-white max-sm:!w-fit
        " />
    {/if}
</div>