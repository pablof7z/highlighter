<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import ReactButton from "$components/buttons/ReactButton.svelte";
	import { requiredTierNamesFor, requiredTiersFor } from "$lib/events/tiers";
	import { urlSuffixFromEvent } from "$utils/url";
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
    import { NDKKind, type NDKEvent, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import { createEventDispatcher } from "svelte";
	import { derived } from "svelte/store";
    import Comment from "$components/Forms/Comment.svelte";
	import { slide } from "svelte/transition";
	import { ChatCircle, Repeat } from "phosphor-svelte";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import { getUserSupportPlansStore, userTiers } from "$stores/user-view";

    export let event: NDKEvent;
    export let urlPrefix: string | undefined = undefined;
    export let skipAuthor: boolean = false;
    const author = event.author;

    let suffixUrl = urlSuffixFromEvent(event);

    const tiers = requiredTiersFor(event);
    // const tierNames = requiredTierNamesFor(event, getUserSupportPlansStore);
    const includesFree = tiers.includes("Free");

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
    <a href="{authorUrl}{urlPrefix??""}/{suffixUrl}" class="
        bg-base-100 rounded-box p-4
        flex flex-col gap-4 pb-6 wrapper w-full {$$props.class??""}
    ">
        {#if $$slots.default}
            <slot />
        {:else}
            <EventContent ndk={$ndk} {event} class="prose article" />
        {/if}

        <!-- <div class="text-white">ID</div>
        {event.id}
        <div class="text-white">Tags</div>
        <pre>{JSON.stringify(event.tags, null, 2)}</pre> -->

        <div class="w-full justify-between items-center inline-flex">
            {#if !skipAuthor}
                <div class="justify-start items-center gap-4 flex">
                    <a href={authorUrl} class="relative flex-none">
                        <Avatar {userProfile} {fetching} user={author} size="small" />
                    </a>
                    <div class="flex flex-col gap-1 items-start w-full truncate">
                        <a href={authorUrl} class="text-white text-[15px] font-semibold truncate">
                            <Name {userProfile} {fetching} user={author} />
                        </a>

                        {#if event.pubkey === $user?.pubkey}
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
            <EventActionButtons {event} on:comment={() => showComment = !showComment} />
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