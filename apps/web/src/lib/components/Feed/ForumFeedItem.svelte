<script lang="ts">
	import { CaretRight } from 'phosphor-svelte';
	import { page } from "$app/stores";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { Avatar, Name, RelativeTime, ndk } from "@kind0/ui-common";
	import { Hexpubkey, NDKEvent, NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable, derived } from "svelte/store";
	import ForumFeedItemReply from "./ForumFeedItemReply.svelte";
	import { getRepliesStore, getConversationRepliesStore, getThreadStore } from "./replies";
	import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import ReplyAvatars from "./ReplyAvatars.svelte";

    export let event: NDKEvent;
    export let op: NDKEvent = event;
    export let mostRecentActivity: number = event.created_at!;
    export let skipTitle = false;
    export let skipReply = false;
    export let maxContentLength = 200;
    export let expandThread = false;
    export let expandReplies = false;
    export let nestedMaxLevel = 2;
    export let showReply = false;

    export let hTag = op.tagValue("h");

    let filter: NDKFilter;
    if (hTag) {
        filter = { "#h": [hTag], "#e": [event.id], kinds: [NDKKind.GroupReply] };
    } else {
        filter = { "#e": [event.id], kinds: [NDKKind.Text] };
    }

    const events = $ndk.storeSubscribe(
        filter,
        { groupable: true, groupableDelay: 500, relaySet: getDefaultRelaySet() }
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

        for (const event of $replies.values()) {
            if (event.kind === NDKKind.GroupReply) authors.add(event.pubkey);
        }

        return Array.from(authors);
    });
</script>

<!-- showReply = {showReply} <br> -->
<!-- expandThread = {expandThread} <br>
expandReplies = {expandReplies} <br>
threadView = {threadView} <br>
op = {!!op} -->

<!-- nestedMaxLevel = {nestedMaxLevel} <br> -->

<a class="w-full text-left p-4 !pb-0 {$$props.class??""}" href="/{authorId}/posts/{event.encode()}">
    <div class="flex flex-col items-start w-full">
        <UserProfile user={event.author} let:userProfile let:fetching>
            <div class="flex flex-row items-start w-full">
                <!-- Avatars -->
                <div class="flex flex-col items-center flex-none w-16 self-stretch">
                        <Avatar user={event.author} {userProfile} class="w-16 h-16 object-cover" type="circle" />
                        <!-- <div class="w-[1px] min-h-[40px] bg-white/20 grow"></div> -->
                </div>

                <!-- Content -->
                <div class="flex flex-col grow w-full pl-4 overflow-auto relative">
                    <!-- Title and time -->
                    <div class="flex flex-row items-start w-full gap-2 relative">
                        <div class="flex flex-col items-start grow">
                            {#if title && !skipTitle && !threadView}
                                <div class="text-lg text-white font-semibold truncate grow">{title}</div>
                            {/if}
                            <div class="text-xs opacity-50">
                                <Name user={event.author} {userProfile} {fetching} />
                            </div>
                        </div>

                        <div class="justify-self-end opacity-50 text-sm h-full absolute right-0">
                            <RelativeTime timestamp={mostRecentActivity * 1000} />
                        </div>
                    </div>

                    <!-- Content / reactions / comment count -->
                    <div class="flex flex-col items-start gap-2 my-4">
                        <!-- Content -->
                        <EventContent ndk={$ndk} {event} content={contentToRender} class={`${$$props.contentClass??""}`} />

                        <!-- event id = {event.id.slice(0, 10)} <br>
                        event count = {$events.length} <br>
                        $replies = {$replies.length} <br>
                        expandReplies = {expandReplies} <br>
                        eventsInThread = {$eventsInThread.length} <br>
                        hTaggedEvents = {$hTaggedEvents.length}<br> -->

                        <!-- TODO: Reactions -->

                        {#if !expandReplies || $replies.length === 0}
                            <button class="" on:click|stopPropagation={() => { showReply = !showReply }} class:hidden={skipReply}>
                                <CommentsButton {event} prefetchedReplies={replies} />
                            </button>
                        {/if}
                    </div>
                </div>
            </div>

            {#if !expandReplies && !expandThread}
                {#if $replies.length > 0 || $eventsInThread.length > 0}
                    <div class="flex flex-row items-end gap-4 w-full">
                        <div class="flex flex-col items-center flex-none w-16">
                            {#if $replies.length > 0}
                                <ReplyAvatars users={$commentAuthors} />
                            {:else}
                                <ReplyAvatars users={[event.pubkey]} />
                            {/if}
                        </div>

                        <!-- Content -->
                        <div class="flex flex-col grow w-full">
                            <div class="flex flex-row items-center gap-4 text-xs text-white/50">
                                {#if $eventsInThread.length > 0}
                                    <button class="opacity-60">
                                        View thread
                                    </button>
                                {/if}

                                {#if $replies.length > 0}
                                    <button class="" on:click|stopPropagation={() => { showReply = !showReply; expandReplies = true }}>
                                        <CommentsButton {event} prefetchedReplies={replies} label="comment" />
                                    </button>
                                {/if}
                            </div>
                        </div>
                    </div>
                {/if}
            {/if}
        </UserProfile>
    </div>
</a>
{#if showReply}
    <ForumFeedItemReply {event} bind:showReply />
{/if}
{#if expandThread && event.id == op.id}
    {#each $eventsInThread as thread, i (thread.id)}
        <svelte:self
            event={thread}
            op={op ?? event}
            threadView={true}
            {expandThread}
            expandReplies={false}
            {nestedMaxLevel}
            maxContentLength={9999}
            {eventsInThread}
            {hTag}
            {hTaggedEvents}
        />
    {/each}
{/if}
{#if expandReplies && $replies.length > 0}
    {#if nestedMaxLevel > 0}
        <div class="bg-white/10 border-white/20 pl-4 border-b-0 border-r-0">
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
