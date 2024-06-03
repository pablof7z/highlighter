<script lang="ts">
	import StylishContainer from './../PageElements/StylishContainer.svelte';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { eventToKind, mainContentKinds } from '$utils/event';
	import ItemLink from './ItemLink.svelte';

    export let id: string;
    export let relays: string[] | undefined = undefined;

    let event: NDKEvent | null | undefined = undefined;

    const relaySet = (relays && relays.length > 0) ? NDKRelaySet.fromRelayUrls(relays, $ndk) : undefined;

    function clicked(e) {
        e.stopPropagation();
        console.log('clicked', e.detail);
    }

    $ndk.fetchEvent(id, { groupable: true, groupableDelay: 250, groupableDelayType: 'at-least', subId: 'embedded-event-wrapper'}, relaySet)
        .then((e) => {
            event = e ? eventToKind(e) : null;
        })

</script>

<div class="w-full my-2">
    {#if event === undefined || event === null}
        <StylishContainer
            class="bg-base-300/50 transition-all duration-300 rounded-box max-md:p-4"
            border={1}
            on:click={clicked}
        >
            {#if event === undefined}
                <span class="p-4">Loading event</span>
                {:else}
                <span class="p-4">Unable to load event</span>
            {/if}
        </StylishContainer>
    {:else if mainContentKinds.includes(event.kind)}
        <ItemLink {event} />
    {:else}
        <EventWrapper
            {event}
            compact={true}
            expandThread={false}
            expandReplies={false}
            showReply={false}
            skipFooter={true}
            skipZaps={true}
            class="text-sm border border-base-300 !p-0"
            disableSwipe
        />
    {/if}
</div>