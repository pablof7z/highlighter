<script lang="ts">
	import { CaretRight } from 'phosphor-svelte';
	import { page } from "$app/stores";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { Avatar, Name, RelativeTime, ZapsButton, ndk } from "@kind0/ui-common";
	import { Hexpubkey, NDKEvent, NDKFilter, NDKKind, eventIsReply } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable, derived } from "svelte/store";
	import ForumFeedItemReply from "./ForumFeedItemReply.svelte";
	import { getRepliesStore, getConversationRepliesStore, getThreadStore } from "./replies";
	import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import ReplyAvatars from "./ReplyAvatars.svelte";
	import RecentZaps from '$components/Events/Zaps/RecentZaps.svelte';
	import RelayIndicator from '$components/Events/RelayIndicator.svelte';
	import ViewConversation from './ViewConversation.svelte';
	import Bookmark from '$components/Bookmark.svelte';
	import { auth } from '@getalby/sdk';

    export let event: NDKEvent;
    export let op: NDKEvent = event;
    export let mostRecentActivity: number = event.created_at!;
    export let skipTitle = false;
    export let skipReply = false;
    export let topLevel = true;
    export let maxContentLength = 1500;
    export let expandThread = false;
    export let positionInThread = 0;
    export let expandReplies = false;
    export let nestedMaxLevel = 2;
    export let showReply = false;
    export let urlPrefix: string;

    export let hTag = op.tagValue("h");

    let filter: NDKFilter;
    if (hTag) {
        filter = { "#h": [hTag], "#e": [event.id], kinds: [NDKKind.GroupReply] };
    } else {
        filter = { "#e": [event.id], kinds: [NDKKind.Text] };
    }

    const events = $ndk.storeSubscribe(
        filter,
        { groupable: true, groupableDelay: 500 }
    );

    /**
     * Events that are tagged with the same h tag as the current event
     */
    let hTaggedEvents = derived(events, $events => {
        return Array.from($events.values()).filter(event => {
            return event.tagValue("h") === hTag;
        });
    });
    export let eventsInThread: Readable<NDKEvent[]> = getThreadStore(op, hTaggedEvents);

    export let threadView = false;

    const authorId = $page.params.id;

    const title = event.tagValue("title");
    const contentToRender = event.content.slice(0, maxContentLength);

    const replies = threadView ? getRepliesStore(event, hTaggedEvents, eventsInThread) : getConversationRepliesStore(op, hTaggedEvents);

    const commentAuthors = derived(replies, $replies => {
        const authors = new Set<Hexpubkey>();

        for (const replyEvent of $replies.values()) {
            authors.add(replyEvent.pubkey);
            if (replyEvent.kind === NDKKind.GroupReply) authors.add(replyEvent.pubkey);
            else if (replyEvent.kind === NDKKind.Text) authors.add(replyEvent.pubkey);
        }

        authors.delete(event.pubkey);

        return Array.from(authors);
    });

    let shouldDisplayVerticalBar = false;
    let shouldExpandBeyondBox = false;

    $: if ((threadView && $eventsInThread.length > 0) || (!expandReplies && ($replies.length > 0))) {
        shouldDisplayVerticalBar = expandThread ? positionInThread < $eventsInThread.length : true;
        shouldExpandBeyondBox = (expandThread && positionInThread < $eventsInThread.length);
    }
</script>

<a class="w-full text-left p-4 pb-0 {$$props.class??""}" href="{urlPrefix}{event.encode()}">
    <div class="flex flex-col items-start w-full">
        <UserProfile
            user={event.author}
            let:userProfile
            let:fetching
            let:authorUrl

        >
            <div class="flex flex-row items-start w-full">
                <!-- Avatars -->
                <div class="flex flex-col items-center flex-none w-16 self-stretch">
                    <a href={authorUrl} on:click|preventDefault>
                        <Avatar user={event.author} {userProfile} class="w-12 h-12 object-cover" type="circle" {fetching} />
                    </a>
                    {#if shouldDisplayVerticalBar}
                        <div class="
                            w-[1px] min-h-[40px] bg-white/20 grow
                            {shouldExpandBeyondBox && "-mb-[64px]"}
                        "></div>
                    {/if}
                </div>

                <!-- Content -->
                <div class="flex flex-col grow w-full pl-4 relative">
                    <!-- Title and time -->
                    <div class="flex flex-row items-start w-full gap-2 relative">
                        <div class="flex flex-col items-start grow">
                            {#if title && !skipTitle && !threadView}
                                <div class="text-lg text-white font-semibold truncate grow">{title}</div>
                            {/if}
                            <div class="text-sm opacity-80">
                                <Name user={event.author} {userProfile} {fetching} />
                            </div>
                        </div>

                        <div class="justify-self-end text-sm h-full absolute right-0">
                            <div class="flex flex-row items-center justify-end gap-2 place-self-end">
                                {#if event.relay}
                                    <RelayIndicator relay={event.relay.url} />
                                {/if}
                                {#each event.onRelays as relay}
                                    {#if relay.url !== event.relay?.url}
                                        <RelayIndicator relay={relay.url} />
                                    {/if}
                                {/each}

                                <div class="opacity-50">
                                    <RelativeTime timestamp={mostRecentActivity * 1000} />
                                </div>
                            </div>

                        </div>
                    </div>

                    <!-- Content / reactions / comment count -->
                    <div class="flex flex-col gap-2">
                        {#if topLevel}
                            <div class="flex flex-row">
                                <ViewConversation {event} {urlPrefix} />
                            </div>
                        {/if}
                        <!-- Content -->
                        <EventContent ndk={$ndk} {event} content={contentToRender} class={`${$$props.contentClass??"text-white/80"} my-2`} />

                        <!-- event id = {event.id.slice(0, 10)} <br>
                        event count = {$events.length} <br>
                        $replies = {$replies.length} <br>
                        expandReplies = {expandReplies} <br>
                        eventsInThread = {$eventsInThread.length} <br>
                        hTaggedEvents = {$hTaggedEvents.length}<br> -->

                        <div class="flex flex-row items-center text-zinc-500 w-full">
                            <div class="flex flex-row gap-2">
                                <RecentZaps {event} count={3} class="text-xs" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

                    <div class="flex flex-row items-end gap-4 w-full mt-2">
                        <div class="flex flex-col items-center flex-none w-16">
                            {#if !expandReplies && !(expandThread && $eventsInThread.length > 0)}
                                {#if $replies.length > 0}
                                    <ReplyAvatars users={$commentAuthors} />
                                {:else if $eventsInThread.length > 0}
                                    <ReplyAvatars users={[event.pubkey]} />
                                {/if}
                            {/if}
                        </div>

                        <div class="flex flex-row grow text-xs w-full justify-between gap-4">
                                <div class="grow">
                                    {#if $eventsInThread.length > 0 && !expandThread}
                                        <button class="opacity-60">
                                            View thread
                                        </button>
                                    {:else if $replies.length > 0}
                                        <button class="" on:click|stopPropagation={() => { showReply = !showReply; expandReplies = true }}>
                                            <CommentsButton {event} prefetchedReplies={replies} label="comment" />
                                        </button>
                                    {/if}
                                </div>

                                <div class="shrink justify-end flex flex-row gap-4 items-center text-white/50">
                                    {#if $replies.length === 0}
                                        <button class="" on:click|stopPropagation={() => { showReply = !showReply }}>
                                            <CommentsButton {event} prefetchedReplies={replies} />
                                        </button>
                                    {/if}

                                    <Bookmark {event} class="w-5 h-5" />

                                    <ZapsButton {event} />
                                </div>
                        </div>
                    </div>
        </UserProfile>
    </div>
</a>
{#if showReply && (!expandThread || $eventsInThread.length === 0)}
    <ForumFeedItemReply {event} bind:showReply />
{/if}
{#if expandThread && event.id == op.id}
    {#each $eventsInThread as thread, i (thread.id)}
        <svelte:self
            event={thread}
            op={op ?? event}
            threadView={true}
            {expandThread}
            topLevel={false}
            positionInThread={i+1}
            expandReplies={false}
            {nestedMaxLevel}
            maxContentLength={9999}
            {eventsInThread}
            {urlPrefix}
            {hTag}
            {hTaggedEvents}
        />
    {/each}
{/if}
{#if expandReplies && $replies.length > 0}
    {#if nestedMaxLevel > 0}
        <div class="flex flex-col discussion-wrapper">
            {#each $replies as reply, i (reply.id)}
                <svelte:self
                    event={reply}
                    op={op ?? event}
                    {expandThread}
                    {expandReplies}
                    nestedMaxLevel={nestedMaxLevel-1}
                    {eventsInThread}
                    {hTag}
                    {hTaggedEvents}
                    {urlPrefix}
                    topLevel={false}
                />
            {/each}
        </div>
    {:else}
        <a href="/{authorId}/posts/{event.encode()}" class="p-4">
            <div class="text-xs text-white/50">
                View discussion
                <CaretRight class="w-4 h-4 inline-block" />
            </div>
        </a>
    {/if}
{/if}
