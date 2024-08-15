<script lang="ts">
	import { NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy, onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { headerTouchFns, layout } from '$stores/layout';
	import { inview } from 'svelte-inview';
	import BackButton from '$components/App/Navigation/BackButton.svelte';
	import { Button } from "$components/ui/button";
	import { throttle } from "@sveu/shared";
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";
	import { Navigation } from "$utils/navigation";
	import { Group } from ".";
    import * as App from "$components/App";

    export let group: Readable<Group>;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let options: NavigationOption[] = [];

    const optionManager = getContext("optionManager") as Navigation;
    optionManager?.options.subscribe(value => options = value);

    const throttledViewChange = throttle((inView: boolean) => {
        if (inView) {
            $layout.header = false;
            $layout.back = { url: "/" }
            $layout.navigation = false;
            $layout.title = undefined;
        } else if (inView === false) {
            $layout.header = undefined;
            $layout.title = $group.name;
            $layout.iconUrl = $group.picture;
            $layout.navigation = options;
        }
    }, 1);

    function inviewchange(e) {
        throttledViewChange(e.detail.inView);
    }

    onMount(() => {
        $layout.navigation = false;
        $layout.header = false;
    })

    onDestroy(() => {
        $layout.header = undefined;
        $layout.navigation = options;
    });
</script>

<App.HeaderShell>
    <!-- Banner -->
    <div class="w-full z-0 relative">
        {#if $group.picture}
            <img src={$group.picture} class="absolute opacity-30 w-full h-full object-full z-1 transition-all duration-300 blur-[100px]">
        {/if}

        <div class="flex flex-row items-end w-full px-4 z-10 pt-4 relative">
            <div class="z-10 left-2 mt-2 top-[var(--safe-area-inset-top)] absolute">
                <BackButton href="/" />
            </div>
            <div class="flex flex-col items-center grow gap-4">
                <img
                    src={$group.picture}
                    class="rounded-full transition-all duration-300 flex-none object-cover w-24 h-24"
                />

                <div class="flex flex-col gap-0" use:inview on:inview_change={inviewchange}>
                    <div class="text-foreground font-bold whitespace-nowrap mb-0 transition-all duration-300 text-xl max-h">
                        {$group.name}
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="flex flex-col gap-4 items-center border-b border-border py-[var(--section-vertical-padding)] z-0 relative responsive-padding px-6 max-w-[var(--content-focused-width)] mx-auto w-full">
        <div class="responsive-padding text-center">
            {$group.about}
        </div>

        {#if $group.members && !$group.isMember}
            <div class="flex flex-row items-center gap-2 w-full justify-between responsive-padding">
                <div class="flex">
                    <AvatarsPill size="small" pubkeys={Array.from($group.members.members)} />
                </div>
                <Button variant="gold" class="px-10">
                    Join
                </Button>
            </div>
        {/if}
        
    </div>

    <HorizontalOptionsList {options} class="py-[var(--section-vertical-padding)] border-y border-border responsive-padding relative" />
</App.HeaderShell>