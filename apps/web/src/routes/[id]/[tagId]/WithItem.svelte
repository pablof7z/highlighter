<script lang="ts">
    import { ndk, user as currentUser } from "@kind0/ui-common";
    import UserProfile from "$components/User/UserProfile.svelte";
	import { page } from "$app/stores";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent, NDKKind, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { getEventType } from "./get-event-type";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { goto } from "$app/navigation";
	import { EVENT_ID_SUFFIX_LENGTH, urlSuffixFromEvent } from "$utils/url";
	import { getSummary } from "$utils/article";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { addReadReceipt } from "$utils/read-receipts";
	import { mainContentKinds } from "$utils/event";
	import type { EventType } from "../../../app";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;
    export let tagId: string | undefined = undefined;
    export let article: NDKArticle | undefined = undefined;
    export let video: NDKVideo | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let urlPrefix: string | undefined = undefined;
    export let event: NDKEvent | undefined = undefined;

    const tagIdExplicit = !!tagId;

    event = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    $: if (!tagIdExplicit) tagId = $page.params.tagId;

    let needsToLoad: boolean;

    startUserView(user);

    onDestroy(() => {
        userSubscription?.unref();
        events?.unsubscribe();
    })

    function getFilter(): NDKFilter[] {
        if (!user.pubkey || !tagId) return [{limit:0}];
        const filters: NDKFilter[] = [{ authors: [user.pubkey], "#d": [tagId] }];

        // 18-char of regex
        const regex = new RegExp(`^[0-9a-fA-F]{${EVENT_ID_SUFFIX_LENGTH}}$`);
        if (tagId.match(regex)) {
            filters.push({ authors: [user.pubkey], "ids": [tagId] });
        }

        return filters;
    }

    let events: NDKEventStore<NDKEvent> | undefined;
    let eosed = false;

    let title: string | undefined;
    let summary: string | undefined;

    // if (!event) {
    //     // check the cache for this event exclusively and only set needsToLoad to true if it's not there
    //     $ndk.fetchEvents(getFilter(), { cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE }).then(e => {
    //         if (e.size === 0) {
    //             needsToLoad = true;
    //         }
    //     });
    // }

    $: if (!events && user.pubkey && tagId) {
        events = $ndk.storeSubscribe(getFilter(), { subId: 'with-item', groupable: false });
        events.onEose(() => {
            eosed = true;
        });
    }

    // Search for an event, if we haven't EOSEd yet, only look for explicitly supported kinds
    $: if (events && !event) {
        const e = Array.from($events) as NDKEvent[];

        const matchingEvent = e.find(e => mainContentKinds.includes(e.kind!)) as NDKEvent | undefined;
        if (matchingEvent) {
            event = matchingEvent;
        } else if (eosed) {
            event = e[0];
        }
    }

    $: if (event?.kind === NDKKind.Article) article = NDKArticle.from(event);
    $: if (event?.kind === NDKKind.HorizontalVideo) video = NDKVideo.from(event);
    $: if (article || video) title = article?.title || video?.title;
    $: if (article && !summary) summary = getSummary(article);
    $: if (video && !summary) summary = video.content;

    let eventType: EventType | undefined;
    let tiersWithFullAccess: string[] | undefined;
    let isFullVersion: boolean;
    let hasAccessToFullVersion: boolean | undefined;

    $: if (event && !eventType) eventType = getEventType(event);
    $: if (event && isFullVersion === undefined) isFullVersion = !event.tagValue("full");
    $: if (event && tiersWithFullAccess === undefined) tiersWithFullAccess = requiredTiersFor(event);
    $: if (event && isFullVersion === false && tiersWithFullAccess && hasAccessToFullVersion === undefined) {
        hasAccessToFullVersion = tiersWithFullAccess.includes($userActiveSubscriptions.get(event.pubkey)) || $currentUser?.pubkey === event.pubkey;
        if (hasAccessToFullVersion) {
            const parts = event.tagValue("full")?.split(/:/) as string[];
            const dTag = parts[2] || parts[0];
            goto(`/${event.author.npub}/${dTag}`);
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
    <LoadingScreen ready={!!event || eosed}>
        <main>
            {#if event}
                <UserProfile user={event.author} bind:authorUrl />

                <slot {event} {urlPrefix} {eventType} {article} {video} {isFullVersion} {authorUrl} />
            {:else}
                Event not found
            {/if}
        </main>
    </LoadingScreen>
{/if}

<!-- <div class="py-24"></div> -->
