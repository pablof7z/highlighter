<script lang="ts">
    import { ndk, pageDrawerToggle, rightSidebar, user as currentUser, Avatar, Textarea, Name } from "@kind0/ui-common";
    import UserProfile from "$components/User/UserProfile.svelte";
	import { page } from "$app/stores";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { debugMode, userActiveSubscriptions } from "$stores/session";
	import type { EventType } from "../../../../app";
	import { getEventType } from "./get-event-type";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { goto } from "$app/navigation";
	import { EVENT_ID_SUFFIX_LENGTH, urlSuffixFromEvent } from "$utils/url";
	import { getSummary } from "$utils/article";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { addReadReceipt } from "$utils/read-receipts";
	import { mainContentKinds } from "$utils/event";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;

    let event: NDKEvent | undefined = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    let tagId: string;

    $: tagId = $page.params.tagId;

    startUserView(user);

    onDestroy(() => {
        userSubscription?.unref();
    })

    let events: NDKEventStore<NDKEvent> | undefined;
    let eosed = false;

    let title: string | undefined;
    let summary: string | undefined;

    $: if (!events && user.pubkey) {
        const filters: NDKFilter[] = [{ authors: [user.pubkey], kinds: mainContentKinds, "#d": [tagId] }];

        // 18-char of regex
        const regex = new RegExp(`^[0-9a-fA-F]{${EVENT_ID_SUFFIX_LENGTH}}$`);
        if (tagId.match(regex)) {
            filters.push({ "ids": [tagId] });
        }

        events = $ndk.storeSubscribe(filters, { groupable: false });
        events.onEose(() => {
            eosed = true;
        });
    }

    $: if (events) event = Array.from($events)[0];

    let article: NDKArticle;

    $: if (event) article = NDKArticle.from(event);
    $: if (article) title = article.title;
    $: if (article) summary = getSummary(article);

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

    let authorUrl: string;
    let urlPrefix: string;

    const url = new URL(window.location.href);
    $: if (event) {
        let eventSuffix = urlSuffixFromEvent(event);
        url.pathname = `${authorUrl}/${eventSuffix}`;
        urlPrefix = url.toString();
    }
</script>

<svelte:head>
    <title>{title}</title>
    <meta name="description" content={summary} />
    <meta property="og:title" content={title} />
    <meta property="og:description" content={summary} />
    <meta property="og:image" content={article?.image} />
</svelte:head>

<LoadingScreen ready={!!event || eosed}>
    <main>
        {#if event}
            <UserProfile user={event.author} bind:authorUrl />

            <slot {event} {urlPrefix} {eventType} {article} {isFullVersion} />

            {#if $debugMode}
                <pre>{JSON.stringify(event.rawEvent(), null, 4)}</pre>
            {/if}
        {:else}
            Event not found
        {/if}
    </main>
</LoadingScreen>

<div class="py-24"></div>
