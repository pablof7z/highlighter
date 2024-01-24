<script lang="ts">
	import ArticleLink from "$components/Events/ArticleLink.svelte";
    import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { Avatar, Name, ndk } from "@kind0/ui-common";
    import { NDKHighlight, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { CaretRight } from "phosphor-svelte";
	import UserProfile from "./User/UserProfile.svelte";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let highlight: NDKHighlight;
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;

    highlight.getArticle().then(result => highlightedArticle = result);

    let highlightedArticleLink: string = "#";
    let articleAuthorUrl: string;

    $: if (highlightedArticle && highlightedArticle instanceof NDKEvent) {
        if (articleAuthorUrl) {
            const suffixUrl = urlSuffixFromEvent(highlightedArticle);
            highlightedArticleLink = `${articleAuthorUrl}/${suffixUrl}`;
        } else {
            highlightedArticleLink = urlFromEvent(highlightedArticle);
        }
    }
</script>

<div class="border-2 border-white/20 rounded-box bg-base-100 w-full">
    <EventContent ndk={$ndk} event={highlight} class="highlight font-serif p-6 leading-8 {$$props.class??""}" />
    {#key highlightedArticle}
        {#if highlightedArticle}
            <a href={highlightedArticleLink} class="
                flex bg-base-200 border-t-2 border-white/20 p-4 text-neutral-500
                hover:text-neutral-400 transition-all duration-200
                rounded-b-box
            ">
                {#if highlightedArticle instanceof NDKArticle}
                    <UserProfile user={highlightedArticle.author} bind:authorUrl={articleAuthorUrl} let:userProfile let:fetching>
                        <div class="flex flex-row gap-4 items-stretch w-full">
                            {#if highlightedArticle.image}
                                <img src={highlightedArticle.image} class="w-12 h-12 object-cover mask mask-squircle" />
                            {:else}
                                <Avatar {userProfile} {fetching} class="w-12 h-12 object-cover" type="square" />
                            {/if}

                            <div class="flex flex-col items-start overflow-hidden whitespace-nowrap truncate flex-grow">
                                <Name user={highlightedArticle.author} class="font-medium text-white" />
                                <div class="w-full truncate">
                                    {highlightedArticle.title}
                                </div>
                            </div>

                            <CaretRight class="w-8 h-8 self-center" />
                        </div>
                    </UserProfile>
                {:else if typeof highlightedArticle === "string"}
                    <span class="text-accent2">{highlightedArticle}</span>
                {/if}
            </a>
        {/if}
    {/key}
</div>
