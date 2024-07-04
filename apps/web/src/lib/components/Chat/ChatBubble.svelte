<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
    import currentUser from "$stores/currentUser";
	import { NDKKind, type NDKEvent, NDKArticle, Hexpubkey, NDKFilter } from "@nostr-dev-kit/ndk";
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

    export let event: NDKEvent;
    export let detailed = false;
    export let skipAuthor = false;
    
    const author = event.author;

    const filter: NDKFilter = { kinds: [9, 11, 12, 7, 5, 9735 ], ...event.filter(), limit: 100 }
    const hTag = event.tagValue("h");

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
    let isGradient = ![NDKKind.Text, NDKKind.GroupChat].includes(event.kind!);
    let authorUrl: string;
</script>

<div 
    class="
    text-left
    flex items-end gap-1
    hover:brightness-150 transition-all duration-100 ease-in-out
    {$$props.class??""}
    {isMine ? 'justify-start flex-row-reverse' : 'justify-start flex-row'}
" class:mb-4={!skipAuthor}
    on:click>
    <UserProfile user={author} bind:userProfile bind:fetching bind:authorUrl />
    <a
        href={authorUrl}
        class:opacity-0={skipAuthor}
    >
        <Avatar user={author} {userProfile} {fetching} size="small" />
    </a>
    <div class="
        bubble-container rounded flex items-stretch justify-stretch w-fit max-w-[90%]
        {isMine ? "bg-accent text-accent-foreground" : "bg-secondary"}
        border border-border p-4
        {isGradient ? "sm:min-w-[28rem]" : ""}
    ">
        <div class="
            w-full flex-1 grow !max-w-none
            {isGradient ? "bg-secondary m-[1px]" : ""}]
        ">
            <div class="text-muted-foreground text-xs">
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
</style>