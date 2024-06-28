<script lang="ts">
	import { Hexpubkey, NDKArticle, NDKKind, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { ndk } from '$stores/ndk';
	import { Readable, derived } from 'svelte/store';
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
	import ZapButton from '$components/buttons/ZapButton.svelte';
	import TopZap from '$components/Events/TopZap.svelte';

    export let article: NDKArticle;

    export let title: string | undefined = article.title;
    export let image: string | undefined = article.image;
    export let author: string | NDKUser = article.author;
    export let description: string | undefined = article.summary;
    export let href: string | undefined = undefined;

    let allTags = $ndk.storeSubscribe({
        kinds: [1, 12, 7, 9802 ], ...article.filter(), authors: Array.from($userFollows)
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

    let summaryLength = description?.length ?? 0;

    export let wideView: boolean = (
        summaryLength > 400 ||
        (summaryLength > 100 && $userFollows.has(article.pubkey))
    );
    let userProfile: NDKUserProfile;
    let authorUrl: string;

    $: if (!image && userProfile?.image) image = userProfile.image;
    $: href = urlFromEvent(article, authorUrl);

    const blossom = createBlossom({ user: article.author });
</script>

<UserProfile bind:userProfile user={author} bind:authorUrl />

<a {href} class="overflow-clip flex-none group h-full flex flex-col gap-2 rounded
    event-wrapper--content
        { wideView ? "md:col-span-2" : ""}">
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
        <div class="absolute top-0 left-0 right-0 bottom-0 z-[2] bg-background bg-opacity-70 w-full h-full backdrop-blur-3xl transition-all duration-300"></div>

        <div
            class="grow relative w-full overflow-clip z-[3] p-4 flex gap-4 flex-col { wideView ? "md:flex-row" : "" }"
        >
            {#if image}
                <img use:blossom alt="" src={image} class="h-auto object-cover w-full rounded { wideView ? "md:w-1/2" : "max-h-[24rem]" }" />
            {/if}

            <!-- Right column or lower part -->
            <div class="flex gap-4 flex-col grow { wideView ? "md:w-1/2 h-full justify-between" : "" }">
                <!-- Top part -->
                <div class="flex flex-col gap-4 grow max-h-[50vh] md:max-h-[25rem] overflow-clip relative">
                    <h3 class="font-bold max-h-[128px] overflow-clip text-foreground text-xl font-serif shrink-0">
                        {title}
                    </h3>

                    <div class="text-sm text-foreground font-normal truncate">
                        {#if author instanceof NDKUser}
                            <AvatarWithName user={author} avatarSize="tiny" avatarType="square" />
                        {:else}
                            {author}
                        {/if}
                    </div>
                    
                    {#if description}
                        <div
                            class="
                                text-muted-foreground overflow-clip grow
                                { description.length > 200 ? 'faded-text' : ''}
                                { wideView ? "text-lg" : "text-sm" }
                            "
                        >
                            {description}
                        </div>
                    {/if}
                </div>

                <div class="flex">
                    <TopZap event={article} />
                </div>

                <EventTags event={article} />

                <!-- Bottom part -->
                <div class="place-self-end flex flex-row w-full gap-4 items-center">
                    <div class="flex flex-row -space-x-2 flex-none grow">
                        {#each $pubkeys.slice(0, 10) as pubkey (pubkey)}
                            <Avatar {pubkey} size="small" />
                        {/each}
                    </div>

                    <div
                        class="grid grid-flow-col w-full items-end justify-evenly bg-background/40 backdrop-blur-lg p-2 rounded shrink basis-0"
                        on:click|stopPropagation|preventDefault={e => e.stopPropagation()}
                    >
                        <!-- <CommentsButton event={article} /> -->

                        <HighlightsWithCountButton event={article} />

                        <BoostButton event={article} />

                        <!-- <ButtonWithCountFromFilter
                            filters={[
                                { kinds: [NDKKind.Reaction], ...article.filter() }
                            ]}
                            color="text-[var(--boost-button)]/30 group-hover:text-[var(--boost-button)]"
                            bgHover="hover:bg-green-400/20"
                            icon={Heart}
                            on:click={() => {
                                article.react("+1", true);
                            }}
                        /> -->

                        <ButtonWithCountFromFilter
                            filters={[
                                { kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet, NDKKind.BookmarkSet], ...article.filter() }
                            ]}
                            color="text-red-500/30 group-hover:text-red-500"
                            bgHover="hover:bg-red-400/20"
                            icon={BookmarkSimple}
                            on:click={() => toggleSaveForLater(article)}
                        />
                    </div>
                </div>
            </div>
        </div>
    </div>
</a>

<style lang="postcss">
    /* Text that fades to transparent at the bottom */
    .faded-text {
        background: linear-gradient(to top, transparent, #ffffff99 50%);
        color: transparent;
        background-clip: text;
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
</style>