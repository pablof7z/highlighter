<script lang="ts">
    import { NDKArticle, NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
    import * as Event from "$components/Event";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import TopPlusRecentZaps from "$components/Events/Zaps/TopPlusRecentZaps.svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { getEventUrl, urlFromEvent, urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";
	import Avatar from "$components/User/Avatar.svelte";
	import Name from "$components/User/Name.svelte";
	import { CaretRight } from "phosphor-svelte";

    export let highlight: NDKHighlight;
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;
    export let skipArticle: boolean = false;

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
</script>

<div class="
    bg-secondary/30
    border rounded
    w-[var(--content-card-width)]
    min-h-[var(--content-card-height)]
    max-h-[calc(var(--content-card-height)*2)]
    flex flex-col divide-y divide-background
">
    <div class="p-4 pb-1">
        <Event.Header event={highlight} />

    </div>
    <a
        href={getEventUrl(highlight)}
        class="p-4 break-words whitespace-normal grow cursor-pointer font-serif highlight">
        <EventContent ndk={$ndk} event={highlight} />
    </a>
    <div class="p-4">
        <ScrollArea orientation="horizontal">
            <TopPlusRecentZaps event={highlight} />
        </ScrollArea>
    </div>

    {#key highlightedArticle}
        {#if highlightedArticle}
            <a href={highlightedArticleLink} class="
                flex bg-secondary border-t-2 border-border p-4
                hover:bg-foreground/10
                hover:text-neutral-400 transition-all duration-200
                rounded-b-box
                truncate
            ">
                {#if highlightedArticle instanceof NDKArticle}
                    <UserProfile user={highlightedArticle.author} bind:authorUrl={articleAuthorUrl} let:userProfile let:fetching>
                        <div class="flex flex-row gap-4 items-stretch w-full">
                            {#if highlightedArticle.image}
                                <img src={highlightedArticle.image} class="w-12 h-12 object-cover rounded" />
                            {:else}
                                <Avatar {userProfile} {fetching} class="w-12 h-12 object-cover" type="square" />
                            {/if}

                            <div class="flex flex-col items-start justify-between overflow-hidden whitespace-nowrap truncate flex-grow">
                                <div class="w-full truncate text-foreground font-medium">
                                    {highlightedArticle.title}
                                </div>
                                <Name npubMaxLength={12} user={highlightedArticle.author} class="text-muted-foreground text-sm" />
                            </div>
                        </div>
                    </UserProfile>
                {:else if typeof highlightedArticle === "string"}
                    <a href="/load?url={encodeURIComponent(highlightedArticle)}" class="text-foreground truncate">{highlightedArticle}</a>
                {:else if highlightedArticle instanceof NDKEvent}
                    <div class="flex flex-row items-center gap-2 overflow-hidden whitespace-nowrap truncate flex-grow">
                        <Avatar user={highlightedArticle.author} class="w-12 h-12 object-cover" type="square" />
                        <div class="w-full truncate text-neutral-500 font-medium">
                            Note by
                            <Name npubMaxLength={12} user={highlightedArticle.author} class="text-foreground text-sm" />
                        </div>
                    </div>
                    
                {/if}
            </a>
        {/if}
    {/key}
</div>