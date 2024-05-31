<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
    import { Avatar, Name, RelativeTime, ndk } from "@kind0/ui-common";
    import currentUser from "$stores/currentUser";
	import { NDKKind, type NDKEvent, NDKArticle, Hexpubkey } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import Article from "$components/List/Article.svelte";
	import { derived } from "svelte/store";
	import { isKind, prettifyReaction, uniquePubkeys } from "$utils/event";
	import { pluralize } from "$utils";
	import { CursorClick, ShareFat } from "phosphor-svelte";

    export let event: NDKEvent;
    export let detailed = false;
    
    const author = event.author;

    const taggingEvents = $ndk.storeSubscribe(
        { ...event.filter(), limit: 100 }
    )

    const replies = derived(taggingEvents, $e => $e.filter(isKind(1)));
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
    let isGradient = ![NDKKind.Text, NDKKind.GroupChat].includes(event.kind!);
    let authorUrl: string;
</script>

<div 
    class="
    text-left
    chat hover:brightness-150 transition-all duration-100 ease-in-out
    {$$props.class??""}
    {isMine ? 'chat-end' : 'chat-start'}
" on:click>
    <UserProfile user={author} bind:userProfile bind:fetching bind:authorUrl />
    <a href={authorUrl} class="chat-image">
        <Avatar user={author} {userProfile} {fetching} size="small" />
    </a>
    <div
        class="
            bubble-container rounded-box flex items-stretch justify-stretch w-fit max-w-[90%] chat-bubble !p-0
            {isGradient ? "sm:min-w-[28rem]" : ""}
        "
        class:bg-gradient={isGradient}
        class:!bg-base-200={!isGradient}
    >
        <div class="
            chat-bubble w-full flex-1 grow !max-w-none
            {isGradient ? "!bg-base-200/50 m-[1px]" : ""}]
        ">
            <div class="chat-header">
            <Name {userProfile} {fetching} />
                <time class="text-xs opacity-50">
                    <RelativeTime timestamp={event.created_at*1000} />
                </time>
            </div>

            {#if event.kind === NDKKind.Article}
                <Article article={NDKArticle.from(event)} />
            {:else}
                <EventContent ndk={$ndk} {event} />
            {/if}

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
</div>

<style lang="postcss">
    .chat-header {
        @apply flex items-center justify-between mb-2 text-xs gap-6;
    }

    .chat-bubble {
        @apply bg-white/10;
    }
</style>