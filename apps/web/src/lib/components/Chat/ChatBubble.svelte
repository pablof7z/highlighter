<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
import { Avatar, Name, RelativeTime, ndk, user } from "@kind0/ui-common";
	import { NDKKind, type NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import Article from "$components/List/Article.svelte";

    export let event: NDKEvent;
    const author = event.author;

    let isMine: boolean;

    isMine = $user?.pubkey === event.pubkey;

    let userProfile: UserProfileType;
    let fetching: boolean;
    let isGradient = event.kind !== NDKKind.GroupChat;
    let authorUrl: string;
</script>

<div class="
    chat
    {isMine ? 'chat-end' : 'chat-start'}
">
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
        class:!bg-base-100={!isGradient}
    >
        <div class="
            chat-bubble w-full flex-1 grow !max-w-none
            {isGradient ? "!bg-base-200/50 m-[1px]" : ""}]
        ">
            <div class="chat-header">
            <Name {userProfile} {fetching} />
                <time class="text-xs opacity-50">
                    <RelativeTime {event} />
                </time>
            </div>

            {#if event.kind === NDKKind.Article}
                <Article article={NDKArticle.from(event)} />
            {:else}
                <EventContent ndk={$ndk} {event} />
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