<script lang="ts">
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKUser } from '@nostr-dev-kit/ndk';
	import Avatar from '$components/User/Avatar.svelte';
    import AvatarWithName from './User/AvatarWithName.svelte';
	import HighlightIcon from '$icons/HighlightIcon.svelte';

    export let title: string;
    export let image: string;
    export let author: string | NDKUser;
    export let description: string | undefined;
    export let href: string | undefined = undefined;
    export let highlights: NDKHighlight[] | undefined = undefined;
    export let skipAuthor = false;

    const highlighters = new Set<Hexpubkey>();

    $: if (highlights) highlights.forEach(h => highlighters.add(h.pubkey));
</script>

<div class="flex flex-col gap-2">
    <a {href} class="w-[326px] h-[277px] overflow-clip flex-none rounded group"
    >
        <div class="relative w-full h-full justify-end flex flex-col">
            <img
                alt=""
                src={image}
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
                            <AvatarWithName user={author} avatarSize="tiny" avatarType="square" />
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

            <div class="flex flex-row w-full justify-between items-center hidden">
                {#if highlights}
                    <div class="z-[5] m-4 flex flex-row flex-nowrap items-center gap-2 bg-foreground/20/80 px-3 py-1 rounded-full text-foreground !w-fit text-xs group">
                        <HighlightIcon class="w-5 h-5 text-foreground opacity-60" />
                        {highlights.length}
                        <div class="flex flex-row flex-nowrap -space-x-4 group-hover:space-x-0">
                            {#each Array.from(highlighters) as highlighter (highlighter)}
                                <Avatar pubkey={highlighter} size="tiny" class="transition-all duration-300" />
                            {/each}
                        </div>
                    </div>
                {/if}

                <!-- <div class="z-[5]">
                    <button class="rounded-full p-1 bg-foreground/20/80 m-4">
                        <BookmarkSimple class="w-4 h-4" />
                    </button>
                </div> -->
            </div>
        </div>
    </a>
</div>