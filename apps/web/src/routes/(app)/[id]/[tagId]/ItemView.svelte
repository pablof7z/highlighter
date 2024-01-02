<script lang="ts">
    import { ndk, pageDrawerToggle, rightSidebar, user as currentUser, Avatar, Textarea, Name } from "@kind0/ui-common";
	import { page } from "$app/stores";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { debugMode, userActiveSubscriptions } from "$stores/session";
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
	import LoadingScreen from "$components/LoadingScreen.svelte";

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
        const filters: NDKFilter[] = [{ authors: [user.pubkey], "#d": [tagId] }];

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
        hasAccessToFullVersion = tiersWithFullAccess.includes($userActiveSubscriptions.get(event.pubkey)) || $currentUser?.pubkey === event.pubkey;
        if (hasAccessToFullVersion) {
            const parts = event.tagValue("full")?.split(/:/) as string[];
            const dTag = parts[2] || parts[0];
            goto(`/${event.author.npub}/${dTag}`);
        }
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

    let videoCommentFocused = false;
    let videoCommentBlurTimeout: any;
    let discussionHovered = false;
    let discussionHoverTimeout: any;

    function onDiscussionHover() {
        discussionHovered = true;
        clearTimeout(discussionHoverTimeout);
    }

    function onDiscussionBlur() {
        discussionHoverTimeout = setTimeout(() => {
            discussionHovered = false;
        }, 500);
    }

    function onVideoCommentFocus() {
        videoCommentFocused = true;
        clearTimeout(videoCommentBlurTimeout);
    }

    function onVideoCommentBlur() {
        const videoCommentBlurTimeout = setTimeout(() => {
            videoCommentFocused = false;
        }, 500);
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
            {#if eventType === "article"}
                <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                    <ArticleView
                        article={NDKArticle.from(event)}
                        on:comment={toggleComments}
                    />

                    <div class="divider my-0"></div>

                    <EventResponses {event} class="max-sm:px-4" />
                </div>
            {:else if eventType === "video"}
                <div class="flex-col justify-start items-start gap-8 flex mx-auto w-full">
                    <VideoView
                        video={NDKVideo.from(event)}
                        on:comment={toggleComments}
                    />

                    <div class="mx-auto max-w-3xl w-full">
                        <div class="divider my-0"></div>

                        <EventResponses
                            {event}
                            on:comment:focus={onVideoCommentFocus}
                            on:comment:blur={onVideoCommentBlur}
                        />
                    </div>
                </div>
            {:else if ["group-note", "short-note"].includes(eventType)}
                <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                    <div class="w-full flex items-center flex-col justify-center">
                        <div class="w-full">
                            <FeedGroupPost {event} />
                        </div>
                    </div>

                    <div class="divider my-0"></div>

                    <EventResponses {event} />

                </div>
            {:else}
                {event.kind}
            {/if}
        {:else}
                Event not found
        {/if}
    </main>
</LoadingScreen>

<div class="py-24"></div>

{#if $debugMode && event}
    <pre>
        {JSON.stringify(event?.rawEvent(), null, 2)}
    </pre>
{/if}