<script lang="ts">
	import { Hexpubkey, NDKHighlight, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';

    export let title: string;
    export let author: string | NDKUser | undefined = undefined;
    export let image: string | undefined = undefined;
    export let description: string | undefined;
    export let href: string | undefined = undefined;
    export let highlights: NDKHighlight[] | undefined = undefined;
    export let skipAuthor = false;
    export let userProfile: NDKUserProfile | undefined | null = undefined;

    const highlighters = new Set<Hexpubkey>();

    $: if (highlights) highlights.forEach(h => highlighters.add(h.pubkey));
</script>

<a {href} class="flex flex-col md:flex-row w-full overflow-clip flex-none group md:max-h-72">
    <img
        alt=""
        src={image ?? userProfile?.image}
        class="
            max-md:max-h-64
            md:h-full
            w-full h-full object-cover
            z-[1] rounded
            md:w-1/2
        "
    />
    <div class="w-full overflow-clip px-4 py-2 flex flex-col">
        <h3 class="font-semibold grow max-h-[64px] overflow-clip text-foreground text-2xl">
            {title}
        </h3>
        {#if description}
            <div class="text-base text-muted-foreground font-normal place-self-end max-h-[10rem] overflow-clip grow">
                {description}
            </div>
        {/if}
        {#if !skipAuthor && author}
            <div class="text-sm text-muted-foreground font-normal truncate pt-2">
                {#if author instanceof NDKUser}
                    <AvatarWithName user={author} avatarSize="tiny" avatarType="square" bind:userProfile />
                {:else}
                    {author}
                {/if}
            </div>
        {/if}
    </div>
</a>