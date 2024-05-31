<script lang="ts">
	import StylishContainer from './../PageElements/StylishContainer.svelte';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import { ndk } from '@kind0/ui-common';
	import { NDKEvent, NDKRelaySet } from "@nostr-dev-kit/ndk";

    export let id: string;
    export let relays: string[] | undefined = undefined;

    let event: NDKEvent;

    const relaySet = relays ? NDKRelaySet.fromRelayUrls(relays, $ndk) : undefined;

    function clicked(e) {
        e.stopPropagation();
        console.log('clicked', e.detail);
    }
</script>

<div class="w-full my-2">
    <StylishContainer
        class="bg-base-300/50 hover:bg-base-300/60 transition-all duration-300 rounded-box max-md:p-4"
        border={1}
        on:click={clicked}
    >
        {#await $ndk.fetchEvent(id, { groupable: true, groupableDelay: 10000, groupableDelayType: 'at-least', subId: 'embedded-event-wrapper'}, relaySet)}
            Loading {id}
        {:then event}
            {#if event}
                <EventWrapper
                    {event}
                    compact={true}
                    expandThread={false}
                    expandReplies={false}
                    showReply={false}
                    skipFooter={true}
                    skipZaps={true}
                />
            {:else}
                <p>Event not found</p>
            {/if}
        {:catch e}
            <p>Error loading event: {e.message}</p>
        {/await}
    </StylishContainer>
</div>