<script lang="ts">
	import CurationWithCountButton from "$components/buttons/CurationWithCountButton.svelte";
    import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import { mainContentKinds } from "$utils/event";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import HighlightsWithCountButton from "$components/buttons/HighlightsWithCountButton.svelte";
	import type { EventType } from "../../../../app";
	import BoostButton from "$components/buttons/BoostButton.svelte";
	import { ZapsButton } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import { hideMobileBottomBar } from "$stores/layout";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
	import UserProfile from "$components/User/UserProfile.svelte";

    export let event: NDKEvent;
    export let urlPrefix: string;
    export let eventType: EventType;
    export let mxClass = "mx-auto";
    export let innerMxClass = mxClass === "mx-auto" ? "sm:-ml-12" : "";

    const eventKind = event.kind!;

    onMount(() => {
        $hideMobileBottomBar = true;
    })

    onDestroy(() => {
        $hideMobileBottomBar = false;
    })
</script>

<div class="my-12"></div>

<footer class="
    fixed bottom-0 w-full max-sm:px-3 py-3 mobile-nav bg-base-100/10
    z-40
    border-t border-white/20
">
    <div class="{mxClass} max-w-3xl">
        <div class="{innerMxClass} flex flex-row gap-8 items-center w-full justify-between">
            <div class="flex flex-row gap-6 max-sm:w-full max-sm:justify-between max-sm:px-3">
                {#if mainContentKinds.includes(eventKind)}
                    <CurationWithCountButton {event} {urlPrefix} />
                {/if}

                <CommentsButton {event} {urlPrefix} />

                <!-- <ReactionsWithCountButton {event} /> -->

                {#if eventType === "article"}
                    <HighlightsWithCountButton {event} {urlPrefix} />
                {/if}

                <BoostButton {event} />

                <ZapsButton {event} />
            </div>

            <div class="place-self-end max-sm:hidden">
                {#if event.author}
                    <UserProfile user={event.author} let:userProfile>
                        <SubscribeButton {userProfile} user={event.author} tiers={getUserSubscriptionTiersStore()} />
                    </UserProfile>
                {/if}
            </div>
        </div>
    </div>
</footer>