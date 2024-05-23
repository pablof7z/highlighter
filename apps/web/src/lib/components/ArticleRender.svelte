<script lang="ts">
	import ItemFooter from './Event/ItemView/ItemFooter.svelte';
	import { getSummary } from '$utils/article';
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "@kind0/ui-common";
	import { type NDKArticle, NDKTag, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import HighlightingArea from './HighlightingArea.svelte';
	import HighlightedContent from './HighlightedContent.svelte';
	import EventTags from './Events/EventTags.svelte';
	import currentUser from '$stores/currentUser';
	import { page } from '$app/stores';
	import BoostButton from './buttons/BoostButton.svelte';
	import ItemViewZaps from './Event/ItemView/ItemViewZaps.svelte';
	import { createBlossom } from '$utils/blossom.js';
	import UserProfile from './User/UserProfile.svelte';
	import ComplexHeaderWithBanner from './PageElements/ComplexHeaderWithBanner.svelte';

    export let article: NDKArticle;
    const author = article.author;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let fillInSummary = true;
    export let url = $page.url.pathname;

    const highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], ...article.filter() },
        { subId: 'article-highlights' }
    )

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
        highlights?.unsubscribe();
    });

    // Check if this user has access to the full article and if they do, redirect them to the full article
    const fullTiers = article.getMatchingTags("tier").map(t => t[1]);

    $: if (fullTiers.includes($userActiveSubscriptions.get(article.pubkey))) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        // goto(`/${author.npub}/${dTag}`);
    }

    let highlightTags: NDKTag[] = article.referenceTags();

    const hTag = article.tagValue("h");
    if (hTag) highlightTags.push(["h", hTag]);

    // add zap splits
    if ($currentUser) {
        highlightTags.push(["zap", $currentUser.pubkey, "2"])
        highlightTags.push(["zap", article.pubkey, "8"])
    }

    const blossom = createBlossom({ user: author });
</script>

<UserProfile user={author} let:userProfile>
    <div dir="auto" class="w-full flex flex-col gap-4">
        <div class="max-sm:-mx-4 h-[50vh] flex relative">
            <img use:blossom src={article.image ?? userProfile?.image} alt={article.title} class="w-full h-full object-cover absolute top-0 left-0 bottom-0 right-0 z-1 w-full opacity-50" />
            <div class="w-full flex flex-col gap-2 absolute bottom-0 z-5 p-4 bg-gradient-to-b from-transparent via-base-100 to-base-100 pt-10">
                {#if article.title}
                    <div class="self-stretch text-white text-4xl font-semibold">
                        {article.title}
                    </div>
                {/if}
                <div class="text-xl text-white/70 font-normal lg:max-h-[6rem] overflow-y-auto scrollbar-hide" class:hidden={!getSummary(article)}>
                    {getSummary(article)}
                </div>

                {#if !isPreview}
                    <ItemViewZaps event={article} />
                {/if}

                <EventTags event={article} />
                
            </div>
        </div>

        <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4 relative">
            <HighlightingArea tags={highlightTags} class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                <HighlightedContent event={article} {highlights} />

                {#if !isFullVersion}
                    <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                        <UpgradeButton event={article} />
                    </div>
                {/if}
            </HighlightingArea>
        </div>
    </div>
</UserProfile>