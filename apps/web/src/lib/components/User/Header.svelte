<script lang="ts">
	import { NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import Avatar from '$components/User/Avatar.svelte';
	import Name from '$components/User/Name.svelte';
	import { layout } from '$stores/layout';
	import { userFollows } from '$stores/session';
	import currentUser from '$stores/currentUser';
	import { inview } from 'svelte-inview';
	import FollowButton from "$components/buttons/FollowButton.svelte";
	import { Button } from "$components/ui/button";
	import { throttle } from "@sveu/shared";
    import * as App from "$components/App";
	import { Nip05 } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import { CheckCircle } from "phosphor-svelte";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | null | undefined = undefined;
    export let fetching: boolean;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let options: NavigationOption[] = [];

    let following: boolean;
    $: following = $userFollows.has(user.pubkey);

    let headerCache: any;

    const throttledViewChange = throttle((inView: boolean) => {
        if (inView) {
            headerCache = $layout.header;
            $layout.header = false;
            $layout.navigation = false;
            $layout.back = { url: "/" }
        } else if (inView === false) {
            $layout.header = undefined;
            $layout.title = userProfile?.name;
            $layout.navigation = options;
        }
    }, 1);

    function inviewchange(e) {
        throttledViewChange(e.detail.inView);
    }

    onMount(() => {
        $layout.header = false;
        headerCache = $layout.header;
        $layout.navigation = false;
    })

    $layout.navigation = false;
</script>

<App.HeaderShell
    class="z-20 w-full sm:min-h-[15rem] flex flex-col"
>
    <!-- Banner -->
    <div class="max-sm:h-[calc(var(--safe-area-inset-top)+6rem)] w-full h-32 relative z-0">
        {#if userProfile?.banner}
            <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top z-1 transition-all duration-300" alt={userProfile?.name}>
        {/if}
    </div>

    <div class="pt-[var(--safe-area-inset-top)] flex flex-row items-end w-full px-4 -mt-[calc(var(--safe-area-inset-top)+2.5rem)] z-1 relative py-[var(--section-vertical-padding)]">
        <div class="flex flex-row items-end grow gap-4">
            <Avatar user={user} {userProfile} {fetching} class="
                transition-all duration-300 flex-none object-cover w-24 h-24
            " size="unconstrained"/>

            <div class="flex flex-col gap-0" use:inview on:inview_change={inviewchange}>
                <Name {user} {userProfile} {fetching} class="text-foreground font-bold whitespace-nowrap mb-0 transition-all duration-300 text-xl max-h" />
                <div class="text-muted-foreground text-sm">
                    <Nip05 ndk={$ndk} {user} {userProfile}>
                        <svelte:fragment slot="badge" let:nip05Valid>
                            {#if nip05Valid}
                                <CheckCircle class="text-accent inline" weight="fill" size={16} />
                            {:else}
                                {nip05Valid}
                            {/if}
                        </svelte:fragment>
                    </Nip05>
                </div>
            </div>
        </div>

        <div class="flex-none">
            {#if user.pubkey !== $currentUser?.pubkey}
                {#if $tiers && $tiers.length > 0}
                {:else}
                    <FollowButton {user} />
                {/if}
            {:else}
                <Button variant="accent" href="/publication/new">
                    Setup creator profile
                </Button>
            {/if}
        </div>
    </div>

    <div class="border-y border-border py-[var(--section-vertical-padding)]">
        <div class="responsive-padding">
            {#if fetching && !userProfile?.about}
                <div class="skeleton h-15 w-48">&nbsp;</div>
            {:else if userProfile?.about}
                {userProfile.about}
            {:else}
                &nbsp;
            {/if}
        </div>
    </div>

    <HorizontalOptionsList {options} class="py-[var(--section-vertical-padding)] border-y border-border" />
</App.HeaderShell>