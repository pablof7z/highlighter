<script lang="ts">
	import { BookmarkSimple, CaretRight, ChatCircle, HourglassHigh, Lightning, Quotes, Repeat, Timer, Warning } from 'phosphor-svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import { Hexpubkey, NDKEvent, NDKFilter, NDKHighlight, NDKKind, NDKTag, NDKUserProfile, NostrEvent,getReplyTag,getRootEventId, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { EventCardDropdownMenu, EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable, derived } from "svelte/store";
	import { getRepliesStore, getConversationRepliesStore, getThreadStore, computeScore } from "./replies";
	import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import ReplyAvatars from "./ReplyAvatars.svelte";
	import RelayIndicator from '$components/Events/RelayIndicator.svelte';
	import ViewConversation from './ViewConversation.svelte';
	import Bookmark from '$components/Bookmark.svelte';
	import MediaCollection from '$components/Events/MediaCollection.svelte';
	import TopPlusRecentZaps from '$components/Events/Zaps/TopPlusRecentZaps.svelte';
	import currentUser from '$stores/currentUser';
	import { UserProfileType } from '../../../app';
	import { goto } from '$app/navigation';
	import BoostButton from '$components/buttons/BoostButton.svelte';
	import { onDestroy } from 'svelte';
    import { createEventDispatcher } from 'svelte';
	import ClientName from '$components/ClientName.svelte';
	import NewPost from './NewPost/NewPost.svelte';
	import HighlightBody from '$components/HighlightBody.svelte';
	import { openModal } from '$utils/modal';
    import QuoteModal from '$modals/QuoteModal.svelte';
	import NewPostModal from '$modals/NewPostModal.svelte';
	import { getAuthorUrl } from '$utils/url';
	import EmbeddedEventWrapper from '$components/Events/EmbeddedEventWrapper.svelte';
	import { isMobileBuild } from '$utils/view/mobile';
	import FailedEventModals from '$modals/FailedEventModals.svelte';
	import SmallZapButton from '$components/buttons/SmallZapButton.svelte';
	import { ndk } from '$stores/ndk';
	import Name from '$components/User/Name.svelte';
	import Avatar from '$components/User/Avatar.svelte';
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';
	import Button from '$components/ui/button/button.svelte';
	import DvmJobFeedback from '$components/Event/Dvm/DvmJobFeedback.svelte';
	import DvmJobResult from '$components/Event/Dvm/DvmJobResult.svelte';
	import ZapReceipt from '$components/Event/ZapReceipt.svelte';
	import { appMobileView } from '$stores/app';
    import EventShell from "$components/Event/Shell.svelte";

    const dispatch = createEventDispatcher();

    export let event: NDKEvent;
    export let author = event.author;
    export let op: NDKEvent = event;
    export let mostRecentActivity: number = event.created_at!;
    export let skipTitle = false;
    export let skipZaps = false;
    export let topLevel = true;
    export let maxContentLength = 1500;
    export let expandThread = false;
    export let positionInThread = 0;
    export let expandReplies = false;
    export let nestedMaxLevel = 2;
    export let showReply: boolean | undefined = undefined;
    export let urlPrefix: string | undefined = undefined;
    export let willShowReply: boolean | undefined = false;
    export let newPostCompact = false;
    export let placeholder: string | undefined = undefined;
    export let skipFooter = false;
    export let compact = false;

    export let disableSwipe = false;

    export let hTag = op.tagValue("h");

    let eventEncoded: string;
    try {
        eventEncoded = event.encode();
    } catch {
        eventEncoded = "";
    }

    if (!urlPrefix) {
        if (isMobileBuild()) urlPrefix = "/a?eventId=";
        else urlPrefix = "/a/";
    }

    let isLastInThread: boolean;

    $: isLastInThread = positionInThread === $eventsInThread.length;

    let filter: NDKFilter;
    if (hTag) {
        filter = { "#h": [hTag], "#e": [event.id], kinds: [NDKKind.GroupReply, NDKKind.Text] };
    } else {
        filter = { "#e": [event.id], kinds: [NDKKind.Text] };
    }

    const events = $ndk.storeSubscribe(
        filter,
        { groupable: true, groupableDelay: 250, subId: 'note-replies', groupableDelayType: 'at-least' }
    );

    onDestroy(() => {
        events?.unsubscribe();
    })

    let replyKind: NDKKind;
    let newPostTags: NDKTag[] = [];

    $: {
        replyKind = event.kind === NDKKind.GroupNote ? NDKKind.GroupReply : NDKKind.Text;
        const replyEvent = new NDKEvent($ndk, { kind: replyKind } as NostrEvent);
        let rootEventId = getRootEventId(event);
        if (!rootEventId && isEventOriginalPost(event)) rootEventId = event.id;
        if (rootEventId) replyEvent.tags.push(["e", rootEventId, "", "root"]);
        replyEvent.tag(event, "reply");
        const hTag = event.tagValue("h");
        if (hTag) { replyEvent.tags.push(["h", hTag]); }
        newPostTags = replyEvent.tags;
    }

    let newPostPlaceholder = "Reply...";

    $: if ($currentUser?.pubkey === event.pubkey) {
        newPostPlaceholder = "Add to this thread";
    } else if (userProfile && userProfile.name) {
        newPostPlaceholder = `Reply to ${userProfile.name}...`;
    } else {
        newPostPlaceholder = `Reply...`;
    }

    export let eventsInThread: Readable<NDKEvent[]> = getThreadStore(op, events);

    export let threadView = false;

    const title = event.tagValue("title");
    const contentToRender = event.content.slice(0, maxContentLength);

    const replies = threadView ? getRepliesStore(event, events, eventsInThread, op) : getConversationRepliesStore(op, events);

    const commentAuthors = derived(replies, $replies => {
        const authors = new Set<Hexpubkey>();

        for (const replyEvent of $replies.values()) {
            authors.add(replyEvent.pubkey);
            if (replyEvent.kind === NDKKind.GroupReply) authors.add(replyEvent.pubkey);
            else if (replyEvent.kind === NDKKind.Text) authors.add(replyEvent.pubkey);
        }

        return Array.from(authors);
    });

    let shouldDisplayVerticalBar = false;
    let shouldExpandBeyondBox = false;

    let noRepliesToShow: boolean = false;
    let noZapsToShow: boolean = false;

    $: {
        if (skipFooter) {
            shouldDisplayVerticalBar = false;
        } else if (willShowReply) {
            shouldDisplayVerticalBar = true;
            shouldExpandBeyondBox = true;
        } else if (expandReplies && $replies.length > 0) {
            shouldDisplayVerticalBar = !willShowReply;
            shouldExpandBeyondBox = true;
        } else if (
            (threadView && $eventsInThread.length > 0) || (!expandReplies && ($replies.length > 0))) {
            shouldDisplayVerticalBar = expandThread ? positionInThread < $eventsInThread.length : true;
            shouldExpandBeyondBox = (expandThread && positionInThread < $eventsInThread.length);
        } else {
            shouldDisplayVerticalBar = false;
            shouldExpandBeyondBox = false;
        }
}

    $: willShowReply = showReply === true;// || (showReply == undefined && isLastInThread && topLevel && isCurrentUser && isNotMobile);

    let autofocusNewPost = false;
    let userProfile: UserProfileType | undefined | null;

    async function contentClicked(e: CustomEvent) {
        const { type, pubkey } = e.detail;

        console.log({type, pubkey});
        
        if (type === "pubkey") {
            const user = $ndk.getUser({pubkey});
            e.preventDefault();
            e.stopImmediatePropagation();
            e.stopPropagation();
            const authorUrl = await getAuthorUrl(user);
            setTimeout(() => goto(authorUrl), 0);
            console.log(user.npub, {authorUrl});
        }
    }

    function noteClicked(e: Event) {
        dispatch('open:note', { event, originalEvent: e });
    }

    function viewConversationClicked(e: CustomEvent) {
        const { event, originalEvent } = e.detail;
        dispatch('open:conversation', { event, originalEvent });
    }

    export let deleted = false;
    function deleteEvent() {
        deleted = true;
        event.delete();
    }

    

    function reply() {
        if (event.pubkey === $currentUser?.pubkey) {
            willShowReply = true;
        } else {
            openModal(NewPostModal, {
                replyTo: event,
            });
        }
    }

    const skipViewConversationKinds = [
        NDKKind.Highlight,
        NDKKind.Zap,
        7377,
        NDKKind.DVMReqTextToSpeech + 1000
    ];

    let swipeActive = false;
</script>

<EventShell
    {event}
    bind:swipeActive
>
    <div class="
        w-full text-left md:p-4 pb-0 max-sm:py-4 max-sm:max-w-[100vw] flex flex-col items-start {$$props.class??""}
        hover:bg-foreground/5
        group
        responsive-padding
    " class:hidden={deleted}>
        <UserProfile
            user={author}
            bind:userProfile
            let:fetching
            let:authorUrl
        >
            <div class="flex flex-row items-start w-full">
                <!-- Avatars -->
                {#if !compact}
                    <div class="flex flex-col items-center flex-none px-1 self-stretch">
                        <a href={authorUrl} class="w-8 sm:w-12">
                            {#key userProfile}
                                <Avatar user={author} {userProfile} class="w-8 sm:w-12 h-8 sm:h-12 object-cover" type="circle" {fetching} />
                            {/key}
                        </a>
                        <div class="
                            w-[1px] bg-white/20 grow transition-all duration-500
                        " style="
                        {shouldDisplayVerticalBar ? 'opacity: 100%' : 'opacity: 0'};
                        {shouldDisplayVerticalBar ? 'height: 100%' : 'height: 0'};
                        min-height: {shouldExpandBeyondBox ? 'calc(100% - 76px)' : '40px'};
                        margin-bottom: {shouldExpandBeyondBox ? '-76px' : '0'};
                        "></div>
                    </div>
                {/if}

                <!-- Content -->
                <div class="
                    flex flex-col overflow-x-clip pl-2 grow
                    {compact ? "w-full" : "w-[calc(100%-3.5rem)]"}
                ">
                    <!-- Title and time -->
                    <div class="
                        flex flex-row w-full gap-2 relative group
                        {!compact ? "items-start" : "items-center"}
                    ">
                        {#if compact}
                            <a href={authorUrl}>
                                <Avatar user={author} {userProfile} class="w-8 h-8 object-cover" type="circle" {fetching} />
                            </a>
                        {/if}

                        <div class="flex flex-col items-start grow">
                            {#if title && !skipTitle && !threadView}
                                <div class="text-lg text-foreground font-semibold truncate grow">{title}</div>
                            {/if}
                            <div class="text-sm opacity-80">
                                <a href={authorUrl}>
                                </a>
                                <Name user={author} {userProfile} {fetching} />
                                {#if !compact}
                                    <ClientName {event} class="ml-2 text-xs opacity-50 inline" />
                                {/if}
                            </div>
                        </div>

                        <div class="justify-self-end text-sm h-full absolute right-0">
                            <div class="flex flex-row items-center justify-end gap-2 place-self-end">
                                <!-- Relay indicators / hidden in mobile -->
                                <div class="flex flex-row items-center max-sm:hidden gap-2 opacity-20 group-hover:opacity-80">
                                    {#if event.relay}
                                        <RelayIndicator relay={event.relay.url} />
                                    {/if}
                                    {#each event.onRelays.slice(0, 4) as relay}
                                        {#if relay.url !== event.relay?.url}
                                            <RelayIndicator relay={relay.url} />
                                        {/if}
                                    {/each}
                                </div>

                                <div class="flex flex-row flex-nowrap gap-2">
                                    <RelativeTime timestamp={mostRecentActivity * 1000} class="opacity-50" />
                                    {#key event.publishStatus}
                                        {#if event.publishStatus !== "success"}
                                            {#if event.publishStatus === "error"}
                                                <button on:click={() => openModal(FailedEventModals, { event })}>
                                                    <Warning class="w-4 h-4 text-red-500" />
                                                </button>
                                            {/if}
                                        {/if}
                                    {/key}
                                    {#if !$appMobileView}
                                        <EventCardDropdownMenu
                                            {event}
                                            enableDelete={$currentUser && $currentUser.pubkey === event.pubkey}
                                            on:delete={deleteEvent}
                                            class="dropdown-end absolute !bg-background z-[9999]"
                                        />
                                    {/if}
                                </div>
                            </div>

                        </div>
                    </div>

                    <!-- Content / reactions / comment count -->
                    <div class="flex flex-col items-stretch justify-stretch basis-0 shrink overflow-x-clip w-full">
                        {#if topLevel && !skipViewConversationKinds.includes(event.kind)}
                            <div class="flex flex-row" class:hidden={noRepliesToShow}>
                                <ViewConversation {event} {urlPrefix} bind:isNoop={noRepliesToShow} on:click={viewConversationClicked} />
                            </div>
                        {/if}
                        <!-- Content -->

                        <a href="{urlPrefix}{eventEncoded}" class="mt-2 event-wrapper--content" on:click={noteClicked}>
                            {#if $$slots.default}
                                <slot />
                            {:else if event.kind === NDKKind.Highlight}
                                <HighlightBody
                                    class="bg-white/10 p-4 rounded-t-box ${$$props.contentClass??""}"
                                    highlight={NDKHighlight.from(event)}
                                />
                            {:else if event.kind === NDKKind.DVMJobFeedback}
                                <DvmJobFeedback {event} />
                            {:else if event.kind >= 6000 && event.kind < 7000}
                                <DvmJobResult {event} {...$$props} />
                            {:else if event.kind === NDKKind.Zap}
                                <ZapReceipt {event} />
                            {:else}
                                <EventContent
                                    ndk={$ndk}
                                    {event}
                                    content={contentToRender}
                                    class={`text-foreground font-normal ${$$props.topLevelContentClass??""} ${$$props.contentClass??""}`}
                                    mediaCollectionComponent={MediaCollection}
                                    on:click={contentClicked}
                                    eventCardComponent={EmbeddedEventWrapper}
                                />
                            {/if}
                        </a>

                        {#if !skipZaps}
                            <div class="flex flex-row items-center text-zinc-500 w-full max-sm:my-2" class:hidden={noZapsToShow}>
                                <div class="flex flex-row gap-2 w-full">
                                    <TopPlusRecentZaps {event} count={3} class="text-xs" bind:isNoop={noZapsToShow} />
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>
            </div>

            {#if !skipFooter}
                <div class="flex flex-row items-end gap-4 w-full footer">
                    {#if (!expandReplies || nestedMaxLevel === 0) && !(expandThread && $eventsInThread.length > 0)}
                        {#if $replies.length > 0}
                            <ReplyAvatars users={$commentAuthors} />
                        {:else if $eventsInThread.length > 0}
                            <ReplyAvatars users={[event.pubkey]} />
                        {/if}
                    {/if}

                    <div class="max-sm:hidden grow text-sm">
                        {#if $eventsInThread.length > 0 && !expandThread}
                                <button class="opacity-60 whitespace-nowrap" on:click={() => expandThread = true }>
                                    View thread
                                </button>
                        {:else if $replies.length > 0 && !expandReplies}
                            <Button variant="outline" size="sm" class="text-left w-full whitespace-nowrap" href="{urlPrefix}{eventEncoded}">
                                View discussion
                            </Button>
                        {/if}
                    </div>

                    <div class:hidden={swipeActive} class="
                        flex flex-row sm:basis-0 text-xs w-full items-center justify-between gap-4
                        grayscale group-hover:grayscale-0
                    ">
                        <div class="w-1/4 flex justify-center items-end">
                            {#if !($eventsInThread.length > 0 && !expandThread) && !($replies.length > 0 && !expandReplies)}
                                <button class="" on:click|stopPropagation={reply}>
                                    <CommentsButton {event} prefetchedReplies={replies} />
                                </button>
                            {/if}
                        </div>

                        <div class="w-1/4 flex justify-center items-end ">
                            <BoostButton {event} on:publish />
                        </div>

                        <div class="w-1/4 flex justify-center items-end">
                            <Bookmark {event} />
                        </div>
                            <!-- <div class="shrink flex flex-row gap-3 items-center text-foreground/50 border grow justify-between"> -->

                        <div class="w-1/4 flex justify-center items-end ">
                            <SmallZapButton {event} />
                        </div>
                    </div>
                </div>
            {/if}
        </UserProfile>
    </div>
</EventShell>
{#if willShowReply}
    <div class="md:pl-4">
        <NewPost
            kind={replyKind}
            extraTags={newPostTags}
            autofocus={autofocusNewPost}
            placeholder={placeholder||newPostPlaceholder}
            bind:collapsed={newPostCompact}
            on:publish={() => {
                showReply = false;
                expandThread = true;
                dispatch('publish', event);
            }}
            on:cancel={() => showReply = false}
        />
    </div>
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
        />
    {/each}
{/if}
{#if expandReplies && $replies.length > 0}
    {#if nestedMaxLevel > 0}
        <div class="flex flex-col discussion-wrapper dropdown-end">
            {#each $replies as reply, i (reply.id)}
                <svelte:self
                    event={reply}
                    op={op ?? event}
                    {expandThread}
                    expandReplies={true}
                    threadView={true}
                    nestedMaxLevel={nestedMaxLevel-1}
                    {eventsInThread}
                    {hTag}
                    {urlPrefix}
                    topLevel={false}
                />
            {/each}
        </div>
    {:else}
        <a href="{urlPrefix}{eventEncoded}" class="p-4">
            <div class="text-xs text-foreground/50">
                View discussion
                <CaretRight class="w-4 h-4 inline-block" />
            </div>
        </a>
    {/if}
{/if}

<style lang="postcss">
    :global(.event-card--dropdown-menu) {
        @apply bottom-0;
    }
</style>