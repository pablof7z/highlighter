<script lang="ts">
    import { ndk, pageDrawerToggle, rightSidebar, user as currentUser, Avatar, Textarea, Name } from "@kind0/ui-common";
    import UserProfile from "$components/User/UserProfile.svelte";
    import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import { page } from "$app/stores";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { debugMode, userActiveSubscriptions } from "$stores/session";
	import ArticleView from "../../../../lib/components/ArticleView.svelte";
	import FeedGroupPost from "$components/Feed/FeedGroupPost.svelte";
	import VideoView from "./VideoView.svelte";
	import EventResponses from "$components/EventResponses.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import CreatorShell from "$components/Creator/CreatorShell.svelte";
	import MoreFromUser from "$components/Creator/MoreFromUser.svelte";
	import { addReadReceipt } from "$utils/read-receipts";
	import WithItem from "./WithItem.svelte";
	import ItemFooter from "./ItemFooter.svelte";
	import ListView from "$components/ListView.svelte";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;

    let event: NDKEvent | undefined = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    let tagId: string;

    $: tagId = $page.params.tagId;

    let readReceiptPosted = false;

    $: if (event && !readReceiptPosted) {
        readReceiptPosted = true;
        console.log("Adding read receipt");
        addReadReceipt(event);
    }
</script>

<WithItem let:event let:article let:video let:urlPrefix let:eventType let:isFullVersion>
    {#if event && eventType}
        {#if eventType === "article" && article}
            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl py-6">
                <ArticleView
                    {article}
                    {isFullVersion}
                />

                <MoreFromUser user={event.author} />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {:else if eventType === "video" && video}
            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl py-6">
                <VideoView
                    {video}
                    {isFullVersion}
                />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} />
        {:else if ["group-note", "short-note"].includes(eventType)}
            <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl">
                <div class="w-full flex items-center flex-col justify-center">
                    <div class="w-full">
                        <FeedGroupPost {event} class="bg-base-200 rounded-box p-6" />
                    </div>
                </div>

                <div class="divider my-0"></div>

                <EventResponses {event} />

            </div>
        {:else if eventType === 'curation'}
            <ListView {event} {urlPrefix} {eventType} />
        {:else}
            <CreatorShell user={event.author}>
                <div class="mx-auto max-w-3xl">
                    <EventWrapper {event} class="bg-base-200 p-6 rounded-box">
                        <EventContent ndk={$ndk} {event} class="prose highlight" />
                    </EventWrapper>
                </div>
            </CreatorShell>
        {/if}
    {/if}
</WithItem>

<div class="py-24"></div>

{#if $debugMode && event}
    <pre>
        {JSON.stringify(event?.rawEvent(), null, 2)}
    </pre>
{/if}