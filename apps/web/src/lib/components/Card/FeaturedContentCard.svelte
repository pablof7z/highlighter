<script lang="ts">
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
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

    const highlighters = new Set<Hexpubkey>();

    $: if (highlights) highlights.forEach(h => highlighters.add(h.pubkey));
</script>

<a {href} class="flex flex-col md:flex-row w-full overflow-clip flex-none group md:max-h-72 relative">
    {#if event && (alwaysShowPinButton || event?.pubkey === $currentUser?.pubkey)}
        <PinButton {event} align="left-2" />
    {/if}
    <img
        alt=""
        src={image ?? userProfile?.image}
        class="
            max-md:max-h-64
            md:h-full
            flex-none
            lg:w-[20rem] h-full object-cover
            z-[1] rounded-t-md md:rounded
        "
    />
    <div class="w-full overflow-clip px-4 py-2 flex flex-col">
        <div class="flex flex-col grow">
            <h3 class="font-semibold max-h-[64px] overflow-clip text-foreground text-2xl">
                {title}
            </h3>
            {#if description}
                <div class="text-base text-muted-foreground font-normal max-h-[10rem] overflow-clip">
                    {description}
                </div>
            {/if}
        </div>
        {#if !skipAuthor && author}
            <div class="text-sm text-muted-foreground font-normal truncate pt-2">
                {#if author instanceof NDKUser}
                    <AvatarWithName user={author} avatarSize="tiny" avatarType="square" bind:userProfile />
                {:else}
                    {author}
                {/if}
            </div>
        {/if}

        <slot />
    </div>
</a>