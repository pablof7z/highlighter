<script lang="ts">
	import { slide } from 'svelte/transition';
	import { Hexpubkey, NDKUser } from '@nostr-dev-kit/ndk';
	import AvatarWithName from './User/AvatarWithName.svelte';
    import { Avatar } from '@kind0/ui-common';
	import HighlightIcon from '$icons/HighlightIcon.svelte';

    export let title: string;
    export let image: string;
    export let author: string | NDKUser;
    export let description: string | undefined;
    export let href: string;
    export let highlights: NDKHighlight[] = [];

    let hover = false;

    const highlighters = new Set<Hexpubkey>();

    $: highlights.forEach(h => highlighters.add(h.pubkey));
</script>

<div class="flex flex-col gap-2">
    <a {href} class="w-[260px] h-[360px] overflow-clip flex-none rounded-box group"
        on:mouseenter={() => hover = true}
        on:mouseleave={() => hover = false}
    >
        <div class="w-[260px] h-[360px] overflow-clip flex-none rounded-box">
            <div class="relative w-full h-full">
                <img
                    alt=""
                    src={image}
                    class="
                        w-full h-full object-cover top-0 left-0 right-0 bottom-0 absolute
                        z-[1]
                    "
                />
                <div class="absolute top-0 left-0 right-0 bottom-0 z-[2] bg-black bg-opacity-50 w-full h-full backdrop-blur-3xl"></div>

                <div class="flex flex-col absolute z-[3] left-5 right-5 top-5 bottom-5">
                    <div class="relative w-full h-full rounded-box overflow-clip">
                        <img
                            src={image}
                            class="w-full h-full object-cover absolute top-0 left-0 right-0 bottom-0"
                        />
                        <div class="flex flex-col absolute bottom-0 z-[4] p-4 bg-base-200 w-full" class:max-h-full={hover}>
                            <h3 class="font-medium grow max-h-[64px] overflow-clip text-white">
                                {title}
                            </h3>
                            {#if hover && description}
                                <div class="text-sm text-zinc-300 pt-4 overflow-clip" transition:slide={{axis: 'y', duration: 500}}>
                                    {description}
                                </div>

                            {/if}
                            <div class="text-sm text-zinc-500 font-normal truncate pt-2">
                                {#if author instanceof NDKUser}
                                    <AvatarWithName user={author} avatarSize="tiny" avatarType="square" />
                                {:else}
                                    {author}
                                {/if}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </a>
    <div class="flex flex-row flex-nowrap items-center gap-2 bg-base-300 px-3 py-1 rounded-full text-base-100-content !w-fit text-xs ml-5 mr-5 group">
        <HighlightIcon class="w-5 h-5 text-base-100-content opacity-60" />
        {highlights.length}
        <div class="flex flex-row flex-nowrap -space-x-4 group-hover:space-x-0">
            {#each Array.from(highlighters) as highlighter (highlighter)}
                <Avatar pubkey={highlighter} size="tiny" class="transition-all duration-300" />
            {/each}
        </div>
    </div>
</div>