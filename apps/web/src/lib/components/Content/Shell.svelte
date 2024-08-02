<script lang="ts">
	import { articleKinds, curationKinds, eventToKind, videoKinds } from "$utils/event";
	import { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKList, NDKRelaySet, NDKUserProfile, NDKVideo } from "@nostr-dev-kit/ndk";
    import * as Article from "$components/Content/Article";
    import * as Video from "$components/Content/Video";
    import * as Note from "$components/Content/Note";
    import * as Highlight from "$components/Content/Highlight";
    import * as Book from "$components/Content/Book";
    import * as Curation from "$components/Content/Curation";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { setContext } from "svelte";
	import { ndk } from "$stores/ndk";
	import { derived } from "svelte/store";
	import { layout } from '$stores/layout.js';
	import { deriveStore } from "$utils/events/derive";
	import Highlight from "$components/Highlight.svelte";

    export let event: NDKEvent;

    let wrappedEvent: NDKArticle | NDKVideo | NDKEvent | NDKList;
    let chapters: NDKArticle[];

    if (event.kind === 30040) {
        wrappedEvent = NDKArticle.from(event)
        try {
            const stupidJsonBody = JSON.parse(event.content)
            if (stupidJsonBody.title)
                (wrappedEvent as NDKArticle).title = stupidJsonBody.title;
        } catch {}

        const eventIds = event.getMatchingTags("e")
        console.log({eventIds})
        
        const relaySet = new NDKRelaySet(new Set([event.relay!]), $ndk);
        console.log({eventIds, relaySet})
        $ndk.fetchEvents(eventIds, undefined, relaySet)
            .then(events => {
                for (const e of eventIds) {
                    for (const event of events) {
                        if (event.id === e[1]) {
                            chapters.push(NDKArticle.from(event));
                        }
                    }
                }

                $layout.sidebar = {
                    component: Book.Sidebar,
                    props: {
                        chapters
                    }
                }
            });
        
    } else {
        wrappedEvent = eventToKind(event);
    }

    let userProfile: NDKUserProfile;
    let authorUrl: string;

    const events = $ndk.storeSubscribe([
        { kinds: [ NDKKind.Text, NDKKind.GroupReply, NDKKind.Zap, NDKKind.Nutzap, NDKKind.Highlight, ], ...wrappedEvent.filter() },
        { kinds: [ NDKKind.Text, NDKKind.GroupReply, NDKKind.GenericRepost, NDKKind.Repost ], "#q": [wrappedEvent.tagId() ] },
        { kinds: [ NDKKind.ArticleCurationSet ], ...wrappedEvent.filter() },
    ], { subId: 'related-events' });

    const wotFilteredEvents =  events; //wotFilteredStore(events);

    const curations = deriveStore(wotFilteredEvents, NDKList, [NDKKind.ArticleCurationSet]);
    const highlights = deriveStore(wotFilteredEvents, NDKHighlight);

    const replies = derived(wotFilteredEvents, $wotFilteredEvents => {
        return $wotFilteredEvents
            .filter(e => [
                NDKKind.Text, NDKKind.GroupReply
            ].includes(e.kind!))
    });

    const tagId = wrappedEvent.tagId();
    const tagReference = wrappedEvent.tagReference();

    const shares = derived(wotFilteredEvents, $wotFilteredEvents => {
        return $wotFilteredEvents
            .filter(e => {
                if ([NDKKind.Repost, NDKKind.GenericRepost].includes(e.kind!))
                    return true;
                const qTag = e.tagValue("q");
                if (qTag === tagId) return true;

                const mentionTag = e.getMatchingTags(tagReference[0], "mention")?.[0];
                if (mentionTag && mentionTag[1] === tagId) return true;
                
                return false;
            });
    });

    const zaps = derived(wotFilteredEvents, $wotFilteredEvents => {
        return $wotFilteredEvents.filter(e => [NDKKind.Zap, NDKKind.Nutzap].includes(e.kind!))
    });

    setContext('curations', curations);
    setContext("wrappedEvent", wrappedEvent);
    setContext('events', events);
    setContext('highlights', highlights);
    setContext('replies', replies);
    setContext('shares', shares);
    setContext('zaps', zaps);
</script>

<UserProfile user={event.author} bind:userProfile bind:authorUrl />

{#if wrappedEvent instanceof NDKArticle}
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full">
        <Article.Header
            article={wrappedEvent}
            {userProfile}
            {authorUrl}
        />

        <slot />
    </div>
{:else if wrappedEvent instanceof NDKVideo}
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full">
        <Video.Header
            video={wrappedEvent}
            {userProfile}
            {authorUrl}
        />

        <slot />
    </div>
{:else if [NDKKind.Text, NDKKind.GroupNote, NDKKind.GroupReply].includes(wrappedEvent.kind)}
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full">
        <Note.Header
            event={wrappedEvent}
            {userProfile}
            {authorUrl}
        />

        <slot />
    </div>
{:else if wrappedEvent.kind === NDKKind.Highlight}
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full">
        <Highlight.Header
            event={wrappedEvent}
            {userProfile}
            {authorUrl}
        />

        <slot />
    </div>
{:else if curationKinds.includes(wrappedEvent.kind)}
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full">
        <Curation.Header
            list={wrappedEvent}
            {userProfile}
            {authorUrl}
        />

        <slot />
    </div>
{:else}
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full">
        <slot />
    </div>
{/if}