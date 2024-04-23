<script lang="ts">
	import { getSummary } from '$utils/article';
	import HighlightIcon from '../icons/HighlightIcon.svelte';
	import { goto } from "$app/navigation";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "@kind0/ui-common";
	import { NDKEvent, type NDKArticle, NDKKind, type NostrEvent, type NDKEventId, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import ItemViewZaps from './ItemViewZaps.svelte';
	import HighlightingArea from './HighlightingArea.svelte';
	import HighlightedContent from './HighlightedContent.svelte';

    export let article: NDKArticle;
    const author = article.author;
    export let editUrl: string | undefined = undefined;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let fillInSummary = true;

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
        goto(`/${author.npub}/${dTag}`);
    }

    editUrl ??= `/articles/${article.tagValue("d")}/edit`;

    let highlightTags: NDKTag[] = article.referenceTags();

    const hTag = article.tagValue("h");
    if (hTag) highlightTags.push(["h", hTag]);
</script>

<div dir="auto" class="w-full flex flex-col gap-4">
    {#if article.title}
        <div class="self-stretch text-white text-4xl font-semibold">
            {article.title}
        </div>
    {/if}

    <div class="text-xl text-white/70 font-normal" class:hidden={!article.summary && !fillInSummary}>
        {getSummary(article)}
    </div>

    {#if !isPreview}
        <ItemViewZaps event={article} />
    {/if}

    <div class="flex flex-row gap-4 flex-wrap">
        {#each article.getMatchingTags("t") as tag, i (i)}
            <div href="/?q={encodeURIComponent("#"+tag[1])}" class="flex-row gap-2 text-white/50 text-sm inline flex-inline bg-white/10 rounded-full px-3 py-1 whitespace-nowrap">
                <span>{tag[1]}</span>
            </div>
        {/each}
    </div>

    {#if article.image}
        <div class="w-full max-h-[50vh] relative overflow-hidden">
            <img class="w-full relative sm:rounded-xl object-cover object-top h-full" src={article.image} />
            <div class="absolute bottom-0 w-full h-2/5 bg-gradient-to-b from-transparent to-black"></div>
        </div>
    {/if}

    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start flex">
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
        </div>
    </div>
</div>

