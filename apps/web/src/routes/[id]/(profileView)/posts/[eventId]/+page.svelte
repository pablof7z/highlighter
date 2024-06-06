<script lang="ts">
	import { ArrowLeft } from 'phosphor-svelte';
	import { page } from "$app/stores";
	import { NDKEvent, NDKUser, isEventOriginalPost, getEventReplyIds, getRootEventId, NDKKind } from "@nostr-dev-kit/ndk";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import ForumFeedItem from "$components/Feed/ForumFeedItem.svelte";
	import { ndk } from "$stores/ndk";
	import { goto } from '$app/navigation';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';

    let id: string;
    let creator: NDKUser | undefined = undefined;
    let eventId: string;

    $: eventId = $page.params.eventId;
    $: {
        id = $page.params.id;
        creator = $page.data.user;
    }

    function expandThread(event: NDKEvent) {
        // if this is the OP, expand
        return isEventOriginalPost(event)
    }

    function expandReplies(event: NDKEvent) {
        return true;
    }

    let event: NDKEvent | undefined = undefined;

    async function back() {
        if (!event) { return goto(`/${id}/posts`); }

        // use window.history.back() to go back to the previous page
        const replyId = event && getEventReplyIds(event)[0];
        const reply = replyId && await $ndk.fetchEvent(replyId);

        const rootId = getRootEventId(event);
        const root = rootId && rootId != replyId && await $ndk.fetchEvent(rootId);

        if (!reply) {
            goto(`/${id}/posts`);
        } else {
            if (reply.pubkey === root?.pubkey) {
                goto(`/${id}/posts/${root?.encode()}`);
            } else {
                goto(`/${id}/posts/${reply.encode()}`);
            }
        }
    }

    let showReply = false;

    // $pageHeader = {
    //     left: {
    //         icon: ArrowLeft,
    //         label: "Back",
    //         fn: back,
    //     },
    //     title: event?.tagValue("title") || "Post",
    //     right: {
    //         fn: () => { showReply = !showReply; },
    //         label: "Reply",
    //     }
    // }

    // onDestroy(() => {
    //     $pageHeader = {};
    // })
</script>

{#if creator}
    <div class="w-full">

        {#key eventId}
        <WithItem tagId={eventId} bind:event>
            {#if event}
                <div class="flex flex-col discussion-wrapper">
                    {#if event.tagValue("title")}
                        <div class="flex flex-col items-start gap-1 p-4">
                            <button on:click={back} class="font-base text-xs">
                                <ArrowLeft class="w-5 h-5 inline-block" />
                                Back to Community posts
                            </button>

                            <button class="text-left truncate text-2xl font-bold text-foreground">{event.tagValue("title")}</button>
                        </div>
                    {/if}

                    {#if event.kind === NDKKind.Text}
                        <EventWrapper
                            {event}
                            creatorUser={creator}
                            expandReplies={expandReplies(event)}
                            expandThread={true}
                            contentClass="text-lg"
                            threadView={true}
                            urlPrefix={`/${id}/posts/`}
                        />
                    {:else}
                        <ForumFeedItem creatorUser={creator} {event} skipTitle={true} contentClass="text-xl leading-10" maxContentLength={999999} expandThread={expandThread(event)} expandReplies={expandReplies(event)} bind:showReply />
                    {/if}
                </div>
            {/if}
        </WithItem>
        {/key}
    </div>
{/if}