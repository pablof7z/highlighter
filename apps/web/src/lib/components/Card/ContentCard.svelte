<script lang="ts">
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { Paperclip, Pinwheel, PushPin } from 'phosphor-svelte';
	import PinButton from './Elements/PinButton.svelte';
	import currentUser from '$stores/currentUser';

    export let event: NDKEvent | undefined = undefined;
    export let title: string;
    export let author: string | NDKUser | undefined = undefined;
    export let image: string | undefined = undefined;
    export let description: string | undefined;
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
</script>

<div class="flex flex-col gap-2" class:in-content-feed={inContentFeed}>
    <a {href} class="
        overflow-clip flex-none rounded group relative
        {width} {height}
        {$$props.class??""}
    " on:click>
        {#if event && (alwaysShowPinButton || event?.pubkey === $currentUser?.pubkey)}
            <PinButton {event} />
        {/if}
        <div class="relative w-full h-full justify-end flex flex-col">
            <img
                alt=""
                src={image ?? userProfile?.image}
                class="
                    w-full object-cover z-[1] h-full
                "
            />

            <div class="
                metadata-container
                relative w-full z-[3] px-4 py-2 palce-self-end
                flex flex-row justify-between items-end
            ">
                <div class="flex flex-col items-start justify-stretch">
                    <h3 class="font-semibold grow max-h-[64px] overflow-clip text-foreground text-lg truncate">
                        {title}
                    </h3>
                    {#if !skipAuthor && author}
                        <div class="text-sm text-muted-foreground font-normal truncate pt-2">
                            {#if author instanceof NDKUser}
                                <AvatarWithName user={author} avatarSize="tiny" avatarType="square" bind:userProfile />
                            {:else}
                                {author}
                            {/if}
                        </div>
                    {:else if description}
                        <div class="text-sm text-muted-foreground font-normal truncate max-w-screen">
                            {description}
                        </div>
                    {/if}
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
        @apply bg-background/90;
    }
</style>