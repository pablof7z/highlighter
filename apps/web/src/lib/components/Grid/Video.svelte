<script lang="ts">
	import { Hexpubkey, NDKKind, NDKUser, NDKUserProfile, NDKVideo } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { ndk } from '$stores/ndk';
	import { derived } from 'svelte/store';
	import { userFollows } from '$stores/session';
	import UserProfile from '$components/User/UserProfile.svelte';
	import { urlFromEvent } from '$utils/url';
	import { onDestroy } from 'svelte';
	import Avatar from '$components/User/Avatar.svelte';
	import EventTags from '$components/Events/EventTags.svelte';
	import CommentsButton from '$components/buttons/CommentsButton.svelte';
	import BoostButton from '$components/buttons/BoostButton.svelte';
	import HighlightsWithCountButton from '$components/buttons/HighlightsWithCountButton.svelte';
	import ButtonWithCountFromFilter from '$components/buttons/ButtonWithCountFromFilter.svelte';
	import { BookmarkSimple, Heart } from 'phosphor-svelte';
	import { toggleSaveForLater } from '$lib/events/save-for-later';
	import { createBlossom } from '$utils/blossom';


    export let video: NDKVideo;

    export let title: string | undefined = video.title;
    export let image: string | undefined = video.thumbnail;
    export let author: string | NDKUser = video.author;
    export let href: string | undefined = undefined;

    let allTags = $ndk.storeSubscribe({
        kinds: [1, 12, 7, 9802 ], ...video.filter(), authors: Array.from($userFollows)
    });

    const pubkeys = derived(allTags, $allTags => {
        const keys = new Set<Hexpubkey>();
        for (const tag of $allTags) {
            keys.add(tag.pubkey);
        }
        return Array.from(keys);
    });

    onDestroy(() => {
        allTags.unsubscribe();
    })

    let colSpan = false;
    let userProfile: NDKUserProfile;
    let authorUrl: string;

    $: if (!image && userProfile?.image) image = userProfile.image;
    $: href = urlFromEvent(video, authorUrl);

    const blossom = createBlossom({ user: video.author });
</script>

<UserProfile bind:userProfile user={author} bind:authorUrl />

<div
    class="
        flex flex-col gap-2 border border-border rounded
        { colSpan ? "md:col-span-2" : ""}
    "
>
    <a {href} class="overflow-clip flex-none rounded group h-full">
        <div class="
            relative w-full h-full items-stretch flex
        ">
            <img
                use:blossom
                alt=""
                src={image}
                class="
                    w-full h-full object-cover top-0 left-0 right-0 bottom-0 absolute
                    z-[1]
                "
            />
            <div class="absolute top-0 left-0 right-0 bottom-0 z-[2] bg-black bg-opacity-50 w-full h-full backdrop-blur-3xl transition-all duration-300 rounded"></div>

            <div
                class="grow relative w-full rounded overflow-clip z-[3] flex gap-4 flex-col { colSpan ? "md:flex-row" : "" }"
            >
                {#if image}
                    <img use:blossom alt="" src={image} class="h-auto object-cover rounded-t w-full { colSpan ? "md:w-1/2" : "" }" />
                {/if}

                <!-- Right column or lower part -->
                <div class="flex gap-4 flex-col grow { colSpan ? "md:w-1/2 h-full justify-between" : "" }">
                    <!-- Top part -->
                    <div class="flex flex-col gap-4 max-h-[50vh] md:max-h-[25rem] overflow-clip relative px-4 grow">
                        <h3 class="font-bold max-h-[128px] overflow-clip text-foreground text-xl font-serif shrink-0">
                            {title}
                        </h3>

                        <div class="text-sm text-muted-foreground font-normal truncate">
                            {#if author instanceof NDKUser}
                                <AvatarWithName user={author} avatarSize="tiny" avatarType="square" />
                            {:else}
                                {author}
                            {/if}
                        </div>
                    </div>

                    <!-- Bottom part -->
                    <div class="place-self-end flex flex-col w-full gap-4">
                        <EventTags event={video} />
                        
                        {#if $pubkeys.length > 0}
                            <div class="flex flex-row -space-x-2 mt-4">
                                {#each $pubkeys.slice(0, 10) as pubkey (pubkey)}
                                    <Avatar {pubkey} size="small" />
                                {/each}
                            </div>
                        {/if}

                        <div
                            class="grid grid-flow-col w-full items-end justify-evenly bg-background/40 backdrop-blur-lg p-2 rounded-b"
                            on:click|stopPropagation|preventDefault={e => e.stopPropagation()}
                        >
                            <CommentsButton event={video} />

                            <HighlightsWithCountButton event={video} />

                            <BoostButton event={video} />

                            <ButtonWithCountFromFilter
                                filters={[
                                    { kinds: [NDKKind.Reaction], ...video.filter() }
                                ]}
                                color="text-[var(--boost-button)]/30 group-hover:text-[var(--boost-button)]"
                                bgHover="hover:bg-green-400/20"
                                icon={Heart}
                                on:click={() => {
                                    video.react("+1", true);
                                }}
                            />

                            <ButtonWithCountFromFilter
                                filters={[
                                    { kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet, NDKKind.BookmarkSet], ...video.filter() }
                                ]}
                                color="text-red-500/30 group-hover:text-red-500"
                                bgHover="hover:bg-red-400/20"
                                icon={BookmarkSimple}
                                on:click={() => toggleSaveForLater(video)}
                            />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </a>
</div>
