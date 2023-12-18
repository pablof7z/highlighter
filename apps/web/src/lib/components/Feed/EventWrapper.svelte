<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import ReactButton from "$components/buttons/ReactButton.svelte";
    import CommentIcon from "$icons/CommentIcon.svelte";
	import RepostIcon from "$icons/RepostIcon.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { urlSuffixFromEvent } from "$utils/url";
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
    import { NDKKind, type NDKEvent, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import { createEventDispatcher } from "svelte";
	import { derived } from "svelte/store";
    import Comment from "$components/Forms/Comment.svelte";
	import { slide } from "svelte/transition";

    const dispatch = createEventDispatcher();

    export let event: NDKEvent;
    export let skipAuthor: boolean = false;
    const author = event.author;

    let suffixUrl = urlSuffixFromEvent(event);

    const tiers = requiredTiersFor(event);
    const includesFree = tiers.includes("Free");

    const taggedEvents = $ndk.storeSubscribe(
        { kinds: [NDKKind.GroupReply, NDKKind.Reaction, NDKKind.GenericRepost], ...event.filter() },
        { subId: "tagged-events" }
    )

    const replies = derived(taggedEvents, ($taggedEvents) => {
        return $taggedEvents.filter(e => e.kind === NDKKind.GroupReply);
    });

    const reposts = derived(taggedEvents, ($taggedEvents) => {
        return $taggedEvents.filter(e => e.kind === NDKKind.GenericRepost);
    });

    const replyingPubkeys = derived(replies, ($replies) => {
        const s = new Set<Hexpubkey>();
        $replies.forEach((e) => { s.add(e.pubkey); });
        return Array.from(s);
    });

    let showComment = false;

    /**
     * Whether the event author is different from the current user.
     * This is used to indent the comment form.
     */
    let differentAuthor = true;

    $: differentAuthor = event.author.pubkey !== $user?.pubkey;

    function reset() {
        showComment = false;
    }
</script>

<UserProfile user={author} let:userProfile let:fetching let:authorUrl>
    <a href="{authorUrl}/{suffixUrl}" class="flex flex-col gap-4 py-6 wrapper w-full {$$props.class??""}">
        {#if $$slots.default}
            <slot />
        {:else}
            <EventContent ndk={$ndk} {event} />
        {/if}

        <!-- <div class="text-white">ID</div>
        {event.id}
        <div class="text-white">Tags</div>
        <pre>{JSON.stringify(event.tags, null, 2)}</pre> -->

        <div class="w-full justify-between items-center inline-flex">
            {#if !skipAuthor}
                <div class="justify-start items-center gap-4 flex">
                    <a href={authorUrl} class="w-12 h-12 relative">
                        <Avatar {userProfile} user={author} class="w-12 h-12 border border-white" />
                    </a>
                    <div class="flex flex-col gap-1 items-start">
                        <a href={authorUrl} class="text-white text-[15px] font-semibold">
                            <Name {userProfile} user={author} />
                        </a>

                        {#if event.pubkey === $user?.pubkey && false}
                            <div class="flex flex-row items-center gap-1 text-xs ">
                                {#if includesFree}
                                    <div class="badge badge-neutral badge-sm">Free</div>
                                {:else}
                                    {#each tiers as tier}
                                        <div class="badge badge-neutral badge-sm">{tier}</div>
                                    {/each}
                                {/if}
                            </div>
                        {/if}
                    </div>
                </div>
            {/if}
            <div class="grow shrink basis-0 flex-col justify-start items-end gap-1 inline-flex">
                <div class="justify-start items-start gap-3 inline-flex">
                    <ReactButton {event} />
                    <button
                        class="w-7 h-7 relative"
                        on:click|preventDefault|stopPropagation={() => { dispatch('comment'); showComment = !showComment; }}>
                        <CommentIcon class="w-7 h-7" />
                    </button>
                    <div class="w-7 h-7 relative">
                        <RepostIcon class="w-7 h-7" />
                    </div>
                </div>
                <div class="self-stretch text-right text-white text-opacity-60 text-sm font-normal leading-[21px]">
                    {#if ($replies.length > 0)}
                        {$replies.length} replies
                    {/if}

                    {#if ($reposts.length > 0)}
                        {$reposts.length} boosts
                    {/if}
                </div>
            </div>
        </div>
    </a>
</UserProfile>
{#if showComment}
    <div
        class="w-full pt-4 pb-4 wrapper"
        class:indent={differentAuthor}
        transition:slide
    >
        <Comment {event} on:published={reset} />
    </div>
{/if}

<style lang="postcss">
    .wrapper {
        @apply border-b border-neutral-800;
    }

    .indent {
        @apply pl-10;
    }
</style>