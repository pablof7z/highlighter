<script lang="ts">
	import { Avatar, Name, ndk } from "@kind0/ui-common";
    import { NDKHighlight, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { CaretRight } from "phosphor-svelte";
	import UserProfile from "./User/UserProfile.svelte";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";
	import AvatarWithName from "./User/AvatarWithName.svelte";
	import { onMount } from "svelte";

    export let highlight: NDKHighlight;
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;
    export let skipArticle: boolean = false;
    export let skipHighlighter = true;
    export let scrollIntoView = false;

    if (!skipArticle) highlight.getArticle().then(result => highlightedArticle = result);

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

    if (scrollIntoView) {
        onMount(() => {
            const mark = container.querySelector("mark");
            if (mark) {
                mark.scrollIntoView({ behavior: "smooth", block: "center" });
            }
        })
    }

    let container: HTMLElement;
</script>

<div class="w-full " bind:this={container}>
    <div class="flex flex-col gap-6 {$$props.class??""}">
        <div class="flex flex-col gap-3 {$$props.contentClass??""}">
            <EventContent ndk={$ndk} event={highlight} class="highlight font-serif leading-8 text-lg" />
            {#if !skipHighlighter}
                <AvatarWithName user={highlight.author} avatarSize="tiny" class="text-xs text-opacity-60" leadingText="highlighted by" />
            {/if}
        </div>
    </div>

    {#key highlightedArticle}
        {#if highlightedArticle}
            <a href={highlightedArticleLink} class="
                flex bg-white/5 border-t-2 border-base-300 p-4 text-neutral-500
                hover:bg-white/10
                hover:text-neutral-400 transition-all duration-200
                rounded-b-box
                truncate
            ">
                {#if highlightedArticle instanceof NDKArticle}
                    <UserProfile user={highlightedArticle.author} bind:authorUrl={articleAuthorUrl} let:userProfile let:fetching>
                        <div class="flex flex-row gap-4 items-stretch w-full">
                            {#if highlightedArticle.image}
                                <img src={highlightedArticle.image} class="w-12 h-12 object-cover mask mask-squircle" />
                            {:else}
                                <Avatar {userProfile} {fetching} class="w-12 h-12 object-cover" type="square" />
                            {/if}

                            <div class="flex flex-col items-start justify-between overflow-hidden whitespace-nowrap truncate flex-grow">
                                <div class="w-full truncate text-neutral-200 font-medium">
                                    {highlightedArticle.title}
                                </div>
                                <Name npubMaxLength={12} user={highlightedArticle.author} class="text-neutral-500 text-sm" />
                            </div>

                            <CaretRight class="w-8 h-8 self-center" />
                        </div>
                    </UserProfile>
                {:else if typeof highlightedArticle === "string"}
                    <a href="/load?url={encodeURIComponent(highlightedArticle)}" class="text-white truncate">{highlightedArticle}</a>
                {/if}
            </a>
        {/if}
    {/key}
</div>
