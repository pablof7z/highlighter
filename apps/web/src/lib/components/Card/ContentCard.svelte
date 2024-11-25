<script lang="ts">
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { Paperclip, Pinwheel, PushPin, Star } from 'phosphor-svelte';
	import PinButton from './Elements/PinButton.svelte';
	import currentUser from '$stores/currentUser';
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';
    import * as Event from '$components/Event';

    export let event: NDKEvent | undefined = undefined;
    export let title: string;
    export let author: string | NDKUser | undefined = undefined;
    export let image: string | undefined = undefined;
    export let description: string | undefined | null = undefined;
    export let href: string | undefined = undefined;
    export let highlights: NDKHighlight[] | undefined = undefined;
    export let skipAuthor = false;
    export let userProfile: NDKUserProfile | undefined | null = undefined;
    export let alwaysShowPinButton = false;

    export let width = 'w-[var(--content-card-width)]';
    export let height = 'h-[var(--content-card-height)]';

    /**
     * Whether to display the card in a feed of the same content type.
     */
    export let inContentFeed = false;

    const highlighters = new Set<Hexpubkey>();

    $: if (highlights) highlights.forEach(h => highlighters.add(h.pubkey));

    let isPaidOnly = false;

    if (event) {
        const hasFree = event.getMatchingTags("f").some(t => t[1] === "Free");
        isPaidOnly = !hasFree && event.hasTag("f");
    }
</script>

<div class="flex flex-col gap-2" class:in-content-feed={inContentFeed}>
    <a {href} class="
        overflow-clip flex-none rounded group relative
        {width} {height}
        {$$props.class??""}
    " on:click>
        {#if event && (alwaysShowPinButton || event?.pubkey === $currentUser?.pubkey)}
            <PinButton {event} align="left-2" />
        {/if}
        <div class="relative w-full h-full justify-end flex flex-col">
            <img
                alt=""
                src={image ?? userProfile?.image}
                class="
                    w-full object-cover z-[1] h-full
                    {$$props.imgClass}
                "
            />

            <div class="top-2 right-2 absolute z-[3] flex flex-row gap-2">
                {#if $$slots.tags}
                    <slot name="tags" />
                {/if}
                {#if event}
                    <Event.Dropdown {event} size="tiny" />
                {/if}
            </div>

            <div class="
                metadata-container
                !bg-black/60
                relative w-full z-[3] px-4 py-2 place-self-end
                flex flex-row justify-between items-end
            ">
                <div class="flex flex-col items-start justify-stretch w-full truncate">
                    <div class="flex flex-row w-full justify-between items-center gap-2">
                        <h3 class="font-semibold grow max-h-[64px] overflow-clip text-white text-lg truncate">
                            {title}
                        </h3>

                        {#if event}
                            <RelativeTime {event} class="text-white/80 text-sm lg:text-xs flex-none" />
                        {/if}
                    </div>
                    <div class="text-sm text-white/80 font-normal truncate pt-2 flex flex-row w-full justify-between">
                        {#if !skipAuthor && author}
                            <span class="grow">
                                {#if author instanceof NDKUser}
                                    <AvatarWithName user={author} avatarSize="tiny" avatarType="square" bind:userProfile />
                                {:else}
                                    {author}
                                {/if}
                            </span>

                            {#if event?.hasTag("full")}
                                <Event.Badges.Preview />
                            {:else if isPaidOnly}
                                <Event.Badges.Exclusive />
                            {/if}
                        {:else if description}
                            <div class="text-sm text-white/80 font-normal truncate max-w-screen">
                                {description}
                            </div>
                        {/if}
                    </div>
                </div>
                
                <slot />
            </div>
        </div>
    </a>
</div>

<style lang="postcss">
    :not(.in-content-feed) img {
        @apply top-0 left-0 right-0 bottom-0 absolute;
    }

    .in-content-feed img {
        @apply rounded;
    }

    :not(.in-content-feed) .metadata-container {
        @apply bg-black/90;
    }
</style>