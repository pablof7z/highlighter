<script lang="ts">
    import { ndk, pageDrawerToggle, rightSidebar, user as currentUser, Avatar, Textarea, Name } from "@kind0/ui-common";
	import { page } from "$app/stores";
	import { type NDKUser, NDKArticle, NDKVideo, NDKEvent, type NDKFilter, type NostrEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
    import { debugMode } from "$stores/session";
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
	import { goto } from "$app/navigation";
	import ArticleView from "$components/ArticleView.svelte";
	import { pageHeader } from "$stores/layout";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { CaretLeft, Lightning } from "phosphor-svelte";
	import Highlight from "$components/Highlight.svelte";
	import { openModal } from "svelte-modals";
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import ThreeColumn from "$components/Layouts/ThreeColumn.svelte";

    export let user: NDKUser = $page.data.user;
    export let rawEvent: NostrEvent | undefined = $page.data.event;
    export let tagId: string | undefined = undefined;
    export let mxClass = "mx-auto"
    export let backUrl = "/";
    export let backTitle: string | undefined = undefined;

    let event: NDKEvent | undefined = rawEvent ? new NDKEvent($ndk, rawEvent) : undefined;

    let readReceiptPosted = false;

    let hasShareApi = false;
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

    let article: NDKArticle | undefined;
    let video: NDKVideo | undefined;

    $: $pageHeader = {
        left: {
            icon: CaretLeft,
            url: backUrl,
            label: backTitle ?? "Back"
        },
        title: article?.title ?? video?.title,
        right: {
            icon: Lightning,
            label: "Subscribe",
            fn: () => {
                if (event?.author) {
                    openModal(BecomeSupporterModal, { user: event.author });
                }
            }
        }
    };
</script>

<WithItem {user} {tagId} bind:event bind:article bind:video let:urlPrefix let:eventType let:isFullVersion bind:authorUrl>
    {#if event && eventType}
        {#if eventType === "article" && article}
            <!-- <ThreeColumn>
                <ArticleView
                    {article}
                    {isFullVersion}
                />

                <MoreFromUser user={event.author} />
            </ThreeColumn> -->
            <MainWrapper
                class="flex-col justify-start gap-2 sm:gap-8 flex pb-6 sm:py-6"
                marginClass={`max-w-3xl ${mxClass}`}
                mobilePadded={false}
            >
                <ArticleView
                    {article}
                    {isFullVersion}
                />

                <MoreFromUser user={event.author} />
            </MainWrapper>

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
            <ListView {event} {urlPrefix} {authorUrl} />
        {:else if eventType === 'highlight'}
            <CreatorShell user={event.author}>
                <div class="max-w-2xl mx-auto w-full">
                    <Highlight highlight={NDKHighlight.from(event)} {urlPrefix} {authorUrl} />
                </div>
            </CreatorShell>
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
