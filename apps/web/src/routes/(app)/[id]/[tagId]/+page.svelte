<script lang="ts">
    import { ndk, pageDrawerToggle, rightSidebar, user as currentUser, Avatar, Textarea, Name } from "@kind0/ui-common";
	import { page } from "$app/stores";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { type NDKUser, NDKKind, NDKArticle, NDKEvent, type NDKFilter, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { onMount, onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { userActiveSubscriptions } from "$stores/session";
	import ArticleView from "./ArticleView.svelte";
	import FeedGroupPost from "$components/Feed/FeedGroupPost.svelte";
	import VideoView from "./VideoView.svelte";
	import type { EventType } from "../../../../app";
	import { getEventType } from "./get-event-type";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { goto } from "$app/navigation";
	import { EVENT_ID_SUFFIX_LENGTH } from "$utils/url";
	import EventResponses from "$components/EventResponses.svelte";
	import { getSummary } from "$utils/article";
	import Logo from "$icons/Logo.svelte";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;

    let event: NDKEvent | undefined = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    console.log(`loading with event`, !!event);

    let { tagId } = $page.params;

    startUserView(user);

    onDestroy(() => {
        userSubscription?.unref();
    })

    let events: NDKEventStore<NDKEvent> | undefined;

    let title: string | undefined;
    let summary: string | undefined;

    $: if (!events && user.pubkey) {
        const filters: NDKFilter[] = [{ authors: [user.pubkey], "#d": [tagId] }];

        // 18-char of regex
        const regex = new RegExp(`^[0-9a-fA-F]{${EVENT_ID_SUFFIX_LENGTH}}$`);
        if (tagId.match(regex)) {
            filters.push({ "ids": [tagId] });
        }

        events = $ndk.storeSubscribe(filters, { groupable: false });
    }

    $: if (events) event = Array.from($events)[0];

    let article = event ? NDKArticle.from(event) : undefined;

    $: if (article) title = article.title;
    $: if (article) summary = getSummary(article);

    let eventType: EventType | undefined;
    let tiersWithFullAccess: string[] | undefined;
    let isFullVersion: boolean | undefined;
    let hasAccessToFullVersion: boolean | undefined;

    $: if (event && !eventType) eventType = getEventType(event);
    $: if (event && isFullVersion === undefined) isFullVersion = event.tagValue("full") === undefined;
    $: if (event && tiersWithFullAccess === undefined) tiersWithFullAccess = requiredTiersFor(event);
    $: if (event && isFullVersion === false && tiersWithFullAccess && hasAccessToFullVersion === undefined) {
        hasAccessToFullVersion = tiersWithFullAccess.includes($userActiveSubscriptions.get(event.pubkey));
        const parts = event.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        goto(`/${event.author.npub}/${dTag}`);
    }

    function toggleComments() {
        if (!$pageDrawerToggle) {
            $pageDrawerToggle = true;
            $rightSidebar = {
                component: EventResponses,
                props: {
                    event,
                    autofocusOnNewComment: true,
                }
            }
        } else {
            $pageDrawerToggle = false;
        }
    }

    let open = false;
</script>

<svelte:head>
    <title>{title}</title>
    <meta name="description" content={summary} />
    <meta property="og:title" content={title} />
    <meta property="og:description" content={summary} />
    <meta property="og:image" content={article?.image} />
</svelte:head>

{#if !event}
    <div class="w-screen h-screen top-0 left-0 fixed flex justify-center items-center">
        <div class="w-24 h-24 animate-pulse scale-150">
            <Logo />

        </div>
    </div>
{:else}
    <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
        {#if eventType === "article"}
            <ArticleView
                article={NDKArticle.from(event)}
                on:comment={toggleComments}
            />
        {:else if eventType === "video"}
            <VideoView
                article={NDKArticle.from(event)}
                on:comment={toggleComments}
            />
        {:else if eventType === "group-note"}
            <div class="w-full flex items-center flex-col justify-center">
                <div class="w-full">
                    <FeedGroupPost {event} />
                </div>
            </div>
        {:else}
            {event.kind}
        {/if}

        <div class="divider my-0"></div>

        <EventResponses {event} />
    </div>
{/if}


<!-- <pre>
    {JSON.stringify(event?.rawEvent(), null, 2)}
</pre> -->