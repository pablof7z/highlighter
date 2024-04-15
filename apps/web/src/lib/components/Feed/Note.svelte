<script lang="ts">
	import { CaretRight } from 'phosphor-svelte';
	import { page } from "$app/stores";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { Avatar, Name, RelativeTime, ZapsButton, ndk } from "@kind0/ui-common";
	import { Hexpubkey, NDKEvent, NDKFilter, NDKKind, NDKTag, NDKUserProfile, NostrEvent, eventIsReply, eventReplies, getRootEventId, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable, derived } from "svelte/store";
	import NewPost from "./NewPost/NewPost.svelte";
	import { getRepliesStore, getConversationRepliesStore, getThreadStore } from "./replies";
	import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import ReplyAvatars from "./ReplyAvatars.svelte";
	import RelayIndicator from '$components/Events/RelayIndicator.svelte';
	import ViewConversation from './ViewConversation.svelte';
	import Bookmark from '$components/Bookmark.svelte';
	import MediaCollection from '$components/Events/MediaCollection.svelte';
	import TopPlusRecentZaps from '$components/Events/Zaps/TopPlusRecentZaps.svelte';
	import currentUser from '$stores/currentUser';
	import { UserProfileType } from '../../../app';

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
    export let showReply: boolean | undefined = undefined;
    export let urlPrefix: string;
    export let willShowReply: boolean | undefined = undefined;

    export let hTag = op.tagValue("h");

    let isLastInThread: boolean;

    $: isLastInThread = positionInThread === $eventsInThread.length;

    let filter: NDKFilter;
    if (hTag) {
        filter = { "#h": [hTag], "#e": [event.id], kinds: [NDKKind.GroupReply] };
    } else {
        filter = { "#e": [event.id], kinds: [NDKKind.Text] };
    }

    const events = $ndk.storeSubscribe(
        filter,
        { groupable: true, groupableDelay: 100, subId: 'note-replies' }
    );

    let replyKind: NDKKind;
    let newPostTags: NDKTag[] = [];

    $: {
        replyKind = event.kind === NDKKind.Text ? NDKKind.Text : NDKKind.GroupReply;
        const replyEvent = new NDKEvent($ndk, { kind: replyKind } as NostrEvent);
        let rootEventId = getRootEventId(event);
        if (!rootEventId && isEventOriginalPost(event)) rootEventId = event.id;
        if (rootEventId) replyEvent.tags.push(["e", rootEventId, "", "root"]);
        replyEvent.tag(event, "reply");
        const hTag = event.tagValue("h");
        if (hTag) { replyEvent.tags.push(["h", hTag]); }
        newPostTags = replyEvent.tags;
    }

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

    let noRepliesToShow: boolean = false;
    let noZapsToShow: boolean = false;

    $: if ((threadView && $eventsInThread.length > 0) || (!expandReplies && ($replies.length > 0))) {
        shouldDisplayVerticalBar = expandThread ? positionInThread < $eventsInThread.length : true;
        shouldExpandBeyondBox = (expandThread && positionInThread < $eventsInThread.length);
    }

    $: willShowReply = showReply === true || (showReply == undefined && isLastInThread && topLevel);

    $: if (expandReplies && $replies.length > 0) {
        shouldDisplayVerticalBar = !willShowReply;
        shouldExpandBeyondBox = true;
    }

    let newPostPlaceholder = "Reply...";

    $: if ($currentUser?.pubkey === event.pubkey) {
        newPostPlaceholder = "Add to this thread";
    } else if (userProfile && userProfile.name) {
        newPostPlaceholder = `Reply to ${userProfile.name}...`;
    } else {
        newPostPlaceholder = `Reply...`;
    }

    let autofocusNewPost = false;
    let userProfile: UserProfileType | undefined | null;
</script>

<div class="
    w-full text-left md:p-4 pb-0 max-sm:py-4 max-sm:max-w-[100vw] flex flex-col items-start {$$props.class??""}
    !font-light
">
    <UserProfile
        user={event.author}
        bind:userProfile
        let:fetching
        let:authorUrl
    >
        <div class="flex flex-row items-start w-full">
            <!-- Avatars -->
            <div class="flex flex-col items-center flex-none w-10 sm:w-16 self-stretch">
                <a href={authorUrl}>
                    <Avatar user={event.author} {userProfile} class="w-8 sm:w-12 h-8 sm:h-12 object-cover" type="circle" {fetching} />
                </a>
                {#if shouldDisplayVerticalBar}
                    <div class="
                        w-[1px] min-h-[40px] bg-white/20 grow
                        {shouldExpandBeyondBox && "-mb-[64px]"}
                    "></div>
                {/if}
            </div>

            <!-- Content -->
            <div class="flex flex-col overflow-x-clip pl-2 md:pl-4 relative grow">
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
                            <!-- Relay indicators / hidden in mobile -->
                            <div class="flex flex-row items-center max-sm:hidden gap-2">
                                {#if event.relay}
                                    <RelayIndicator relay={event.relay.url} />
                                {/if}
                                {#each event.onRelays.slice(0, 4) as relay}
                                    {#if relay.url !== event.relay?.url}
                                        <RelayIndicator relay={relay.url} />
                                    {/if}
                                {/each}
                            </div>

                            <div class="opacity-50">
                                <RelativeTime timestamp={mostRecentActivity * 1000} />
                            </div>
                        </div>

                    </div>
                </div>

                <!-- Content / reactions / comment count -->
                <div class="flex flex-col items-stretch justify-stretch basis-0 shrink overflow-x-clip">
                    {#if topLevel}
                        <div class="flex flex-row" class:hidden={noRepliesToShow}>
                            <ViewConversation {event} {urlPrefix} bind:isNoop={noRepliesToShow} />
                        </div>
                    {/if}
                    <!-- Content -->
                    <a href="{urlPrefix}{event.encode()}" class="mt-2">
                        <EventContent
                            ndk={$ndk}
                            {event}
                            content={contentToRender}
                            class={`${$$props.contentClass??"text-white/80"}`}
                            mediaCollectionComponent={MediaCollection}
                        />
                    </a>

                    <div class="flex flex-row items-center text-zinc-500 w-full max-sm:my-2 mt-4" class:hidden={noZapsToShow}>
                        <div class="flex flex-row gap-2">
                            <TopPlusRecentZaps {event} count={3} class="text-xs" bind:isNoop={noZapsToShow} />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="flex flex-row items-end gap-4 w-full mt-2">
            <div class="flex flex-col items-center flex-none w-10 sm:w-16">
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
                        {:else if $replies.length > 0 && !expandReplies}
                            <button class="" on:click|stopPropagation={() => { expandReplies = true }}>
                                <CommentsButton {event} prefetchedReplies={replies} label="comment" />
                            </button>
                        {/if}
                    </div>

                    <div class="shrink justify-end flex flex-row gap-3 items-center text-white/50">
                        {#if $replies.length === 0 || !($replies.length > 0 && !expandReplies)}
                            <button class="" on:click|stopPropagation={() => { autofocusNewPost = showReply = !showReply }}>
                                <CommentsButton {event} prefetchedReplies={replies} />
                            </button>
                        {/if}

                        <Bookmark {event} class="w-6 h-6" />

                        <ZapsButton {event} />
                    </div>
            </div>
        </div>
    </UserProfile>
</div>
{#if willShowReply}
    <NewPost
        kind={replyKind}
        extraTags={newPostTags}
        bind:showReply
        autofocus={autofocusNewPost}
        placeholder={newPostPlaceholder}
    />
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
            showReply={expandThread && i === $eventsInThread.length-1}
            expandReplies={false}
            {nestedMaxLevel}
            class={$$props.contentClass}
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
                    expandReplies={false}
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
