<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { urlSuffixFromEvent } from "$utils/url";
    import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { Avatar, Name, RelativeTime, ndk, user } from "@kind0/ui-common";
    import { type NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventCardDropdownMenu, EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import Comment from "$components/Forms/Comment.svelte";
	import { slide } from "svelte/transition";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import { goto } from "$app/navigation";

    export let event: NDKEvent;
    export let urlPrefix: string | undefined = undefined;
    export let skipAuthor: boolean = false;
    export let skipActions = false;
    export let reverse = false;
    export let deleted = false;
    const author = event.author;

    let suffixUrl = urlSuffixFromEvent(event);

    const tiers = requiredTiersFor(event);
    // const tierNames = requiredTierNamesFor(event, getUserSubscriptionTiersStore);
    const includesFree = tiers.includes("Free");

    let showComment = false;

    /**
     * Whether the event author is different from the current user.
     * This is used tothe comment form.
     */
    let differentAuthor = true;
    $: differentAuthor = event.pubkey !== $user?.pubkey;

    function reset() {
        showComment = false;
    }

    function deleteEvent() {
        deleted = true;
        event.delete();
    }
</script>

<UserProfile user={author} let:userProfile let:fetching let:authorUrl>
    <a href="{authorUrl}{urlPrefix??""}/{suffixUrl}" class="
        p-4
        flex flex-col gap-4 pb-6 wrapper w-full {$$props.class??""}
    " class:hidden={deleted}>
        {#if reverse}
            <div class="flex flex-row w-full justify-between items-stretch">
                <AvatarWithName user={author} {userProfile} {fetching} />

                <div class="flex flex-row gap-2 items-center" on:click|preventDefault|stopPropagation|stopImmediatePropagation>
                    <RelativeTime {event} class="text-neutral-500 text-sm font-normal" />

                    <EventCardDropdownMenu
                        {event}
                        enableDelete={$user && $user.pubkey === event.pubkey}
                        on:delete={deleteEvent}
                        class="dropdown-end right-0" on:open={() => {
                        goto(`/e/${event.encode()}`);
                    }} />
                </div>
            </div>
        {/if}

        {#if $$slots.default}
            <slot />
        {:else}
            <EventContent ndk={$ndk} {event} class="text-lg !font-light" />
        {/if}

        <div class="w-full justify-between items-center inline-flex">
            {#if !skipAuthor && !reverse}
                <div class="justify-start items-center gap-4 flex">
                    <a href={authorUrl} class="relative flex-none">
                        <Avatar {userProfile} {fetching} user={author} size="small" />
                    </a>
                    <div class="flex flex-col gap-1 items-start w-full truncate">
                        <a href={authorUrl} class="text-white text-[15px] font-medium truncate">
                            <Name  npubMaxLength={12} {userProfile} {fetching} user={author} />
                        </a>

                        {#if event.pubkey === $user?.pubkey}
                            <!-- <div class="flex flex-row items-center gap-1 text-xs ">
                                {#if includesFree}
                                    <div class="badge badge-neutral badge-sm">Free</div>
                                {:else}
                                    {#each tiers as tier}
                                        <div class="badge badge-neutral badge-sm">{tier}</div>
                                    {/each}
                                {/if}
                            </div> -->
                        {/if}
                    </div>
                </div>
            {/if}
            {#if event.sig && event.id && !skipActions}
                <EventActionButtons {event} on:comment={() => showComment = !showComment} />
            {/if}
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