<script lang="ts">
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import PinButton from './Elements/PinButton.svelte';
	import currentUser from '$stores/currentUser';
	import TopZap from '$components/Events/TopZap.svelte';
	import { eventIsPaid, eventIsPreview, eventIsInGroup } from '$utils/preview';
    import * as Event from '$components/Event';
	import RelatedEvents from '$components/Feed/Item/RelatedEvents.svelte';
	import * as Groups from '$components/Groups';

    export let event: NDKEvent | undefined = undefined;
    export let title: string;
    export let author: string | NDKUser | undefined = undefined;
    export let image: string | undefined = undefined;
    export let description: string | undefined;
    export let href: string | undefined = undefined;
    export let skipAuthor = false;
    export let userProfile: NDKUserProfile | undefined | null = undefined;
    export let alwaysShowPinButton = false;
    export let isPreview = event ? eventIsPreview(event) : undefined;
    export let isPaid = event ? eventIsPaid(event) : undefined;
    export let skipCommunity = false;
    export let isInGroup = !skipCommunity ? (event ? eventIsInGroup(event) : undefined) : false;
</script>

<a {href} class="flex flex-col w-full overflow-clip flex-none group relative !no-underline py-2 gap-2">
    {#if event && (alwaysShowPinButton || event?.pubkey === $currentUser?.pubkey)}
        <PinButton {event} align="left-2" />
    {/if}
    <img
        alt=""
        src={image ?? userProfile?.image}
        class="
            max-md:max-h-64 overflow-clip
            max-h-72
            flex-none
            object-cover
            z-[1] md:rounded-t-md md:rounded
        "
    />
    <div class="w-full overflow-clip px-4 flex flex-col">
        <div class="flex flex-col grow">
            <h3 class="font-semibold max-h-[64px] overflow-clip text-foreground text-2xl">
                {title}
            </h3>

            {#if isInGroup || isPaid || isPreview}
                <div class="flex flex-row gap-2 items-center">
                    {#if isInGroup}
                        <Groups.PublishedToPills {event} size="sm" />
                    {/if}
                    
                    {#if isPreview}
                        <Event.Badges.Preview />
                    {:else if isPaid}
                        <Event.Badges.Exclusive />
                    {/if}
                </div>
            {/if}

            <div class="flex flex-row justify-between w-full">
                {#if !skipAuthor && author}
                    <div class="text-sm text-foreground font-normal truncate">
                        {#if author instanceof NDKUser}
                            <AvatarWithName user={author} avatarSize="xs" avatarType="square" bind:userProfile />
                        {:else}
                            {author}
                        {/if}
                    </div>
                {/if}
            </div>
            
            {#if description}
                <div class="text-base text-muted-foreground font-normal max-h-[10rem] overflow-clip">
                    {description}
                </div>
            {/if}
        </div>

        {#if event}
            <div class="mt-2 flex flex-row w-full">
                <TopZap {event} class="w-fit" />
                <div class="grow"></div>
                <RelatedEvents {event} />
            </div>
        {/if}

        <slot />
    </div>
</a>