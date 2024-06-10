<script lang="ts">
	import StylishContainer from './../PageElements/StylishContainer.svelte';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import { ndk } from "$stores/ndk";
	import { NDKArticle, NDKEvent, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { eventToKind, mainContentKinds } from '$utils/event';
	import ItemLink from './ItemLink.svelte';
	import Article from '$components/Grid/Article.svelte';
	import { Button } from '$components/ui/button';

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

    let showMore = false;
</script>

<div class="w-full my-2">
    {#if event === undefined || event === null}
        <div
            class="bg-secondary text-secondary-foreground transition-all duration-300 rounded p-4 border"
        >
            {#if event === undefined}
                <span class="p-4">Loading event</span>
            {:else}
                <span class="p-4">Unable to load event</span>

                <Button forceNonMobile variant="secondary" size="sm" on:click={() => showMore = true}>Details</Button> 

                {#if showMore}
                    <p>
                        The event with ID {id} could not be loaded.
                    </p>
                {/if}
            {/if}
        </div>
    {:else if event.kind === NDKKind.Article}
        <Article article={NDKArticle.from(event)} wideView />
    {:else if mainContentKinds.includes(event.kind)}
        <div class="w-full border border-border">
            <ItemLink {event} class="event-wrapper--content" />
        </div>
    {:else}
        <EventWrapper
            {event}
            compact={true}
            expandThread={false}
            expandReplies={false}
            showReply={false}
            skipFooter={true}
            skipZaps={true}
            class="text-sm border border-border md:!p-2 rounded"
            disableSwipe
        />
    {/if}
</div>