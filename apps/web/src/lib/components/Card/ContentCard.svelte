<script lang="ts">
	import { Hexpubkey, NDKHighlight, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';

    export let title: string;
    export let author: string | NDKUser;
    export let image: string | undefined = undefined;
    export let description: string | undefined;
    export let href: string | undefined = undefined;
    export let highlights: NDKHighlight[] | undefined = undefined;
    export let skipAuthor = false;
    export let userProfile: NDKUserProfile | undefined | null = undefined;

    const highlighters = new Set<Hexpubkey>();

    $: if (highlights) highlights.forEach(h => highlighters.add(h.pubkey));
</script>

<div class="flex flex-col gap-2">
    <a {href} class="w-[326px] h-[277px] overflow-clip flex-none rounded group"
    >
        <div class="relative w-full h-full justify-end flex flex-col">
            <img
                alt=""
                src={image ?? userProfile?.image}
                class="
                    w-full h-full object-cover top-0 left-0 right-0 bottom-0 absolute
                    z-[1]
                "
            />

            <div class="relative w-full overflow-clip z-[3] px-4 py-2 palce-self-end bg-background/80 backdrop-blur-xl">
                <h3 class="font-semibold grow max-h-[64px] overflow-clip text-foreground text-lg truncate">
                    {title}
                </h3>
                {#if !skipAuthor}
                    <div class="text-sm text-muted-foreground font-normal truncate pt-2 place-self-end">
                        {#if author instanceof NDKUser}
                            <AvatarWithName user={author} avatarSize="tiny" avatarType="square" bind:userProfile />
                        {:else}
                            {author}
                        {/if}
                    </div>
                {:else if description}
                    <div class="text-sm text-muted-foreground font-normal truncate place-self-end">
                        {description}
                    </div>
                {/if}
            </div>
        </div>
    </a>
</div>