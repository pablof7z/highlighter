<script lang="ts">
    import UserProfile from "$components/User/UserProfile.svelte";
	import { page } from "$app/stores";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent, NDKKind, filterFromId, NIP33_A_REGEX, NDKRelay, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { urlSuffixFromEvent } from "$utils/url";
	import { getSummary } from "$utils/article";
	import { addReadReceipt } from "$utils/read-receipts";
	import { isEventFullVersion, mainContentKinds } from "$utils/event";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { nip19 } from "nostr-tools";
	import { getEventType } from "./get-event-type";
	import { EventType } from "../../../../app";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;
    export let tagId: string | undefined = undefined;
    export let article: NDKArticle | undefined = undefined;
    export let video: NDKVideo | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let urlPrefix: string | undefined = undefined;
    export let event: NDKEvent | undefined = undefined;

    export let title: string | undefined = undefined;
    export let image: string | undefined = undefined;

    let loading = false;
    let eosed = false;

    const tagIdExplicit = !!tagId;

    event = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    $: if (!tagIdExplicit) tagId = $page.params.tagId;

    let needsToLoad: boolean;
    let authed: boolean;

    // if we are still loading after 1 second, show the loading screen
    setTimeout(() => { loading = true; }, 1000);

    const relaySet = getDefaultRelaySet();
    const relay = Array.from(relaySet.relays)[0];
    relay.on("authed", () => {
        if (events && !authed) {
            events.unsubscribe();
        }
        events = $ndk.storeSubscribe(getFilter(), { groupable: false, subId: 'with-item-fetcher', closeOnEose: true });
        events.onEose(() => { eosed = true; });

        authed = true;
    });

    const fetchEventFromRecentlyConnectedRelay = async (relay: NDKRelay) => {
        // console.log('fetchEventFromRecentlyConnectedRelay', relay)
        // console.log('fetching event from recently connected relay', relay.url, getFilter());
        
        const relaySet = new NDKRelaySet(new Set([relay]), $ndk);
        const es = await $ndk.fetchEvents(getFilter(), { subId: 'with-item-fetcher-per-relay', groupable: false }, relaySet);

        for (const e of es) {
            if (e.created_at! > (event?.created_at || 0)) {
                // console.log('found newer event on relay ' + relay.url, e.created_at);
                event = e;
            }
        }
    }

    $ndk.pool.on("relay:connect", fetchEventFromRecentlyConnectedRelay);

    onDestroy(() => {
        events?.unsubscribe();
        $ndk.pool.off("relay:ready", fetchEventFromRecentlyConnectedRelay);
    })

    function getFilter(): NDKFilter[] {
        if (!tagId) return [{limit:0}];

        let filters: NDKFilter[] = [{ "#d": [tagId], kinds: mainContentKinds }];
        
        if (tagId.match(NIP33_A_REGEX)) {
            const [kind, pubkey, dTag] = tagId.split(":");
            filters = [{ kinds: [parseInt(kind) as NDKKind], authors: [pubkey], "#d": [dTag] }];
        }
        
        if (user) filters[0].authors = [user.pubkey];

        // A nip19 entity
        try {
            nip19.decode(tagId);
            filters = [filterFromId(tagId)];
        } catch {
        }

        return filters;
    }

    let events: NDKEventStore<NDKEvent> | undefined;

    let summary: string | undefined;

    // if (!event) {
    //     // check the cache for this event exclusively and only set needsToLoad to true if it's not there
    //     $ndk.fetchEvents(getFilter(), { cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE }).then(e => {
    //         if (e.size === 0) {
    //             needsToLoad = true;
    //         }
    //     });
    // }

    // Search for an event, if we haven't EOSEd yet, only look for explicitly supported kinds
    $: if ($events && !event) {
        const e = Array.from($events) as NDKEvent[];

        const matchingEvent = e.find(e => mainContentKinds.includes(e.kind!)) as NDKEvent | undefined;
        if (matchingEvent) {
            event = matchingEvent;
        } else if (eosed) {
            event = e[0];
        }
    }

    let ignoreRelayHint = false;

    $: if (!events && tagId) {
        // console.log({tagId})
        if (tagId.match(NIP33_A_REGEX) && !ignoreRelayHint) {
            // console.log('nip33_a detected', tagId);
            try {
                const {type, data} = nip19.decode(tagId);
                // console.log('nip19 decoded', type, data);
                
                if (Array.isArray(data?.relays) && data.relays.length > 0) {
                    const relaySet = NDKRelaySet.fromRelayUrls((data.relays as string[]), $ndk);
                    events = $ndk.storeSubscribe([filterFromId(tagId)], { groupable: false });
                    events.onEose(() => { eosed = true; });
                }
                events = $ndk.storeSubscribe([filterFromId(tagId)], { groupable: false });
                events.onEose(() => { eosed = true; });
            } catch {
            }
            events = $ndk.storeSubscribe(getFilter(), {  groupable: false });
            events.onEose(() => { eosed = true; });
        } else {
            events = $ndk.storeSubscribe(getFilter(), {  groupable: false });
            events.onEose(() => { eosed = true; });
        }
    }

    $: if (event && event.kind) {
        switch (event.kind) {
            case NDKKind.Article: 
                article = NDKArticle.from(event);
                title = article.title;
                image = article.image;
                summary = getSummary(article);
                break;
            case NDKKind.HorizontalVideo:
                video = NDKVideo.from(event);
                title = video.title;
                image = video.thumbnail;
                summary = video.content;
                break;
            default:
                title = undefined;
                image = undefined;
                break;
        }
    }

    export let eventType: EventType | undefined = undefined;
    let tiersWithFullAccess: string[] | undefined;
    let isFullVersion: boolean;
    let hasAccessToFullVersion: boolean | undefined;

    $: if (event && !eventType) eventType = getEventType(event);
    $: if (event) isFullVersion = isEventFullVersion(event);
    $: if (event && tiersWithFullAccess === undefined) tiersWithFullAccess = requiredTiersFor(event);
    $: if (event && isFullVersion === false && tiersWithFullAccess && hasAccessToFullVersion === undefined) {
        hasAccessToFullVersion = tiersWithFullAccess.includes($userActiveSubscriptions.get(event.pubkey)) || $currentUser?.pubkey === event.pubkey;
        if (hasAccessToFullVersion) {
            const parts = event.tagValue("full")?.split(/:/) as string[];
            const dTag = parts[2] || parts[0];
            // goto(`/${event.author.npub}/${dTag}`);
        }
    }

    let readReceiptPosted = false;

    $: if (event && !readReceiptPosted) {
        readReceiptPosted = true;
        addReadReceipt(event);
    }

    const url = new URL($page.url.toString());
    $: if (event) {
        let eventSuffix = urlSuffixFromEvent(event);
        url.pathname = `${authorUrl}/${eventSuffix}`;
        urlPrefix = url.toString();
    }
</script>

<svelte:head>
    <title>{title}</title>
    {#if summary}
        <meta name="description" content={summary} />
        <meta property="og:description" content={summary} />
    {/if}
    <meta property="og:title" content={title} />
    {#if article?.image || video?.thumbnail}
        <meta property="og:image" content={article?.image || video?.thumbnail} />
    {/if}
</svelte:head>

{#if needsToLoad || (!!event || eosed)}
    {#if event}
        <UserProfile user={event.author} bind:authorUrl let:userProfile>
            <slot {event} {urlPrefix} {eventType} {article} {video} {isFullVersion} {authorUrl} {userProfile} />
        </UserProfile>

        {#if $debugMode}
            <pre class="max-w-5xl overflow-auto">{JSON.stringify(event.rawEvent(), null, 4)}</pre>
        {/if}
    {:else if eosed}
        <p>Unable to find the event.</p>
    {:else if loading}
        <p>Still looking for the event...</p>
    {/if}
{/if}

<!-- <div class="py-24"></div> -->
