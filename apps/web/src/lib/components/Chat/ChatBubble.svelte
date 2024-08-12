<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
    import currentUser from "$stores/currentUser";
	import { NDKKind, NDKArticle, Hexpubkey, NDKEvent, NDKFilter, getReplyTag, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import Article from "$components/List/Article.svelte";
	import { derived } from "svelte/store";
	import { isKind, prettifyReaction, uniquePubkeys } from "$utils/event";
	import { pluralize } from "$utils";
	import Name from "$components/User/Name.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import { ndk } from "$stores/ndk";
	import Avatar from "$components/User/Avatar.svelte";
	import LoadEvent from "$components/Event/LoadEvent.svelte";
	import { unicodeEmojiRegex } from "$utils/const";
	import MediaCollection from "$components/Events/MediaCollection.svelte";
	import EmbeddedEventWrapper from "$components/Events/EmbeddedEventWrapper.svelte";
	import { markGroupEventSeen } from "$stores/notifications";

    export let event: NDKEvent;
    export let detailed = false;
    export let skipAvatar = false;
    export let skipName = false;
    export let skipTime = false;

    const author = event.author;

    const filter: NDKFilter = { kinds: [9, 10, 1311, 11, 12, 7, 5, 9735 ], ...event.filter(), limit: 100 }
    const hTag = event.tagValue("h");

    markGroupEventSeen(hTag!, event);

    if (hTag) {
        filter["#h"] = [hTag];
    } else {
        console.log("no h tag", event.rawEvent())
    }

    const taggingEvents = $ndk.storeSubscribe(
        filter
    )

    const replies = derived(taggingEvents, $e => $e.filter(isKind(1, 9)));
    const reactions = derived(taggingEvents, $e => $e.filter(isKind(NDKKind.Reaction)));
    const replyingPubkeys = derived(replies, $replies => uniquePubkeys($replies));

    const groupedReactions = derived(reactions, $r => {
        const grouped = new Map<string, Set<Hexpubkey>>();
        $r.forEach(r => {
            const key = prettifyReaction(r.content);
            const set = grouped.get(key) ?? new Set();
            set.add(r.pubkey);
            grouped.set(key, set);
        });

        const res: Record<string, Array<Hexpubkey>> = {};
        for (const [content, pubkeys] of grouped) {
            res[content] = Array.from(pubkeys);
        }

        return res;
    });

    let isMine: boolean;

    isMine = $currentUser?.pubkey === event.pubkey;

    let userProfile: UserProfileType;
    let fetching: boolean;
    let isGradient = ![NDKKind.Text, NDKKind.GroupChat, 10, 1311].includes(event.kind!);
    let authorUrl: string;

    let replyTo = event.getMatchingTags("e", "reply")[0];

    let isEmoji = event.content.trim().length <= 2 && !!event.content.match(unicodeEmojiRegex);
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<div 
    class="
    text-left
    flex items-end gap-1
    cursor-pointer transition-all duration-100 ease-in-out
    responsive-padding
    {$$props.class??""}
    {isMine ? 'justify-start flex-row-reverse' : 'justify-start flex-row'}
" on:click class:mb-4={!skipAvatar}>
    <UserProfile user={author} bind:userProfile bind:fetching bind:authorUrl />
    {#if !skipAvatar}
        <a
            href={authorUrl}
            class:opacity-0={skipAvatar}
        >
            <Avatar user={author} {userProfile} {fetching} size="tiny" />
        </a>
    {:else}
        <div class="w-6"></div>
    {/if}
    {#if isEmoji}
        <div class="text-7xl mt-2">{event.content}</div>
    {:else}
    <div class="
        rounded flex items-stretch justify-stretch w-fit max-w-[90%]
        {isMine ? "bg-accent text-accent-foreground" : "bg-secondary"}
        px-3 py-2 max-sm:py-2
        {isGradient ? "sm:min-w-[28rem]" : ""}
        { skipAvatar ? ( isMine ? "!rounded-br-none" : "!rounded-bl-none" ) : "" }
        { skipName ? ( isMine ? "!rounded-tr-none" : "!rounded-tl-none" ) : "" }
    " style={
        (skipAvatar || skipName) ? "margin-top: 1px;" : ""
    }>
        <div class="
            w-full flex-1 grow
            break-words max-w-[70vw] overflow-clip
            {isGradient ? "bg-secondary m-[1px]" : ""}]
        ">
            {#if !skipName || !skipTime}
                <div class="
                    { !isMine ? "text-muted-foreground" : "text-accent-foreground/60" }
                    text-xs flex flex-row items-center gap-6 w-full justify-between">
                    {#if !skipName}
                        <Name {userProfile} {fetching} class="truncate" />
                    {:else}
                        <div class="grow"></div>
                    {/if}
                    <time class="whitespace-nowrap">
                        <RelativeTime {event} />
                    </time>
                </div>
            {/if}

            {#if event.kind === NDKKind.Article}
                <Article article={NDKArticle.from(event)} />
            {:else}
                {#if replyTo}
                    <LoadEvent {event} tag={replyTo} let:event>
                        {#if event}
                            <div class="bg-foreground/20 border-l-4 border-foreground truncate p-1 px-2 flex flex-col text-sm mb-1">
                                <Name pubkey={event.pubkey} class="text-muted-foreground" />:
                                {event?.content}
                            </div>
                        {/if}
                    </LoadEvent>
                {/if}
                {#if event.kind !== NDKKind.GroupChat && event.kind !== 10}
                    {event.kind}
                {/if}
                <EventContent
                    ndk={$ndk}
                    mediaCollectionComponent={MediaCollection}
                    eventCardComponent={EmbeddedEventWrapper}
                    {event}
                />
            {/if}

            <slot />

            {#if $replyingPubkeys.length > 0}
                <div class="flex flex-row items-center gap-2 border-t border-white/20 mt-4 -mx-4 p-4 pb-0">
                    <div class="flex flex-row items-center -space-x-2">
                        {#each $replyingPubkeys as pubkey (pubkey)}
                            <Avatar {pubkey} size="tiny" />
                        {/each}
                    </div>

                    <span class="text-xs">
                        {$replyingPubkeys.length} {pluralize($replyingPubkeys.length, "reply", "replies")}
                    </span>
                </div>
            {/if}

            {#if detailed && Object.keys($groupedReactions).length > 0}
                <div class="flex flex-col items-start gap-2 border-t border-white/20 -mx-4 px-4 pt-4">
                    {#each Object.entries($groupedReactions) as [reaction, pubkeys] (reaction)}
                        <div class="flex flex-row items-center gap-1">
                            <span class="text-lg">{reaction}</span>
                            <div class="flex flex-row items-center -space-x-2">
                                {#each pubkeys as pubkey (pubkey)}
                                    <Avatar {pubkey} size="tiny" />
                                {/each}
                            </div>
                        </div>
                    {/each}
                </div>
            {/if}
        </div>
    </div>
    {/if}
</div>

<style lang="postcss">
    .chat-header {
        @apply flex items-center justify-between mb-2 text-xs gap-6;
    }
</style>