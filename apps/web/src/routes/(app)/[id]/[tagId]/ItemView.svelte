<script lang="ts">
    import { ndk, pageDrawerToggle, rightSidebar, user as currentUser, Avatar, Textarea, Name } from "@kind0/ui-common";
	import { page } from "$app/stores";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { debugMode } from "$stores/session";
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
	import MobileHeader from "$components/Page/MobileHeader.svelte";
	import { Export, Share } from "phosphor-svelte";
	import { goto } from "$app/navigation";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;
    export let tagId: string | undefined = undefined;
    export let mxClass = "mx-auto"
    export let backUrl = "/explore";
    export let backTitle: string | undefined = undefined;

    let event: NDKEvent | undefined = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    let readReceiptPosted = false;

    let hasShareApi = false;
    let article: NDKArticle | undefined = undefined;
    let authorUrl: string;

    $: if (typeof navigator !== "undefined") {
        hasShareApi = !!navigator.share;
    }

    $: if (event && !readReceiptPosted) {
        readReceiptPosted = true;
        console.log("Adding read receipt");
        addReadReceipt(event);
    }

    function buttonClicked() {
        if (hasShareApi) {
            navigator.share({
                text: event?.content,
                url: window.location.href
            });
        } else {
            goto(authorUrl);
        }
    }
</script>

<WithItem {user} {tagId} let:event let:article let:video let:urlPrefix let:eventType let:isFullVersion bind:authorUrl>
    {#if event && eventType}
        {#if eventType === "article" && article}
            <MobileHeader
                backButton={backUrl}
                {backTitle}
                title={article.title}
            >
                <button
                    slot="button"
                    on:click={buttonClicked}
                    class="w-8 h-8"
                >
                    {#if hasShareApi}
                        <Export class="w-full h-full" />
                    {:else}
                        <Avatar user={event.author} size="small" type="square" class="object-cover" />
                    {/if}
                </button>
            </MobileHeader>

            <div class="flex-col justify-start items-start gap-2 sm:gap-8 flex {mxClass} max-w-3xl pb-6 sm:py-6">
                <ArticleView
                    {article}
                    {isFullVersion}
                />

                <MoreFromUser user={event.author} />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} {mxClass} />
        {:else if eventType === "video" && video}
            <div class="flex-col justify-start items-start gap-8 flex {mxClass} max-w-3xl py-6">
                <VideoView
                    {video}
                    {isFullVersion}
                />
            </div>

            <ItemFooter {event} {urlPrefix} {eventType} {mxClass} />
        {:else if ["group-note", "short-note"].includes(eventType)}
            <div class="flex-col justify-start items-start gap-8 flex {mxClass} max-w-3xl">
                <div class="w-full flex items-center flex-col justify-center">
                    <div class="w-full">
                        <FeedGroupPost {event} class="bg-base-200 rounded-box p-6" />
                    </div>
                </div>

                <div class="divider my-0"></div>

                <EventResponses {event} />

            </div>
        {:else if eventType === 'curation'}
            <ListView {event} {urlPrefix} />
        {:else}
            <CreatorShell user={event.author}>
                <div class="{mxClass} max-w-3xl">
                    <EventWrapper {event} class="bg-base-200 p-6 rounded-box">
                        <EventContent ndk={$ndk} {event} class="prose highlight" />
                    </EventWrapper>
                </div>
            </CreatorShell>
        {/if}
    {/if}
</WithItem>

{#if $debugMode && event}
    <pre>
        {JSON.stringify(event?.rawEvent(), null, 2)}
    </pre>
{/if}