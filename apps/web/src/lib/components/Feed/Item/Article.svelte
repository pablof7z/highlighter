<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import RelatedEvents from "./RelatedEvents.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { getSummary, readTime } from "$utils/article";
	import Swipe from "$components/Swipe.svelte";
	import { NavigationOption } from "../../../../app";
	import { BookBookmark, BookmarkSimple } from "phosphor-svelte";
	import { toast } from "svelte-sonner";
    import { saveForLater } from "$lib/actions/Events/save-for-later.js";
	import PublishedToPills from "$components/Groups/PublishedToPills.svelte";
	import { eventIsInGroup, eventIsPaid, eventIsPreview } from "$utils/preview";
	import Name from "$components/User/Name.svelte";
    import * as Event from '$components/Event';

    export let article: NDKArticle;
    export let skipAuthor = false;
    export let href: string | undefined = undefined;
    export let index: number | undefined = undefined;
    export let skipCommunity = false;

    const summary = getSummary(article, true);

    $: href = href || `/a/${article.encode()}`;

    const time = readTime(article.content);

    async function addToReadLater() {
        await saveForLater(article);
        toast.success("Article saved for later");
    }

    const leftOptions: NavigationOption[] = [
        {
            icon: BookmarkSimple,
            name: "Read Later",
            class: '!bg-green-500',
            fn: addToReadLater
        }
    ]

    export let isPreview = article ? eventIsPreview(article) : undefined;
    export let isPaid = article ? eventIsPaid(article) : undefined;
</script>

<Swipe
    {leftOptions}
    preview={index === 0}
>
<a {href} class="flex flex-col gap-2 min-h-[5rem] lg:min-h-[10rem] {$$props.class??""}">
    <div class="grid grid-cols-3 items-start gap-y-1 gap-x-4">
        <div class="col-span-2">
            <div class="flex flex-row gap-4 text-muted-foreground lg:text-xs text-sm w-full items-center justify-between mb-2">
                {#if !skipCommunity && eventIsInGroup(article)}
                    <PublishedToPills event={article} />
                {:else if !skipAuthor}
                    <Name user={article.author} class="font-light !text-xs truncate" />
                {/if}
            </div>
        </div>

        <div class="flex flex-row items-center gap-2 justify-end">
            {#if article.created_at}
                <Badge variant="secondary" class="font-light text-muted-foreground">
                    <RelativeTime event={article} />
                </Badge>
            {/if}
        </div>

        <div class="col-span-2 flex flex-col">
            <div class="flex flex-col gap-0">
                <h2 class="text-lg md:text-lg font-medium mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{article.title}</h2>

                <div class="col-span-3 mt-1 flex flex-row gap-1 mb-2 grow">
                    <RelatedEvents event={article} />
        
                    <Badge variant="secondary" class="font-light text-muted-foreground whitespace-nowrap w-fit">
                        {time} read
                    </Badge>

                    {#if isPreview}
                        <Event.Badges.Preview />
                    {:else if isPaid}
                        <Event.Badges.Exclusive />
                    {/if}
                </div>
                
                <p class="text-sm text-muted-foreground max-h-[2.5rem] sm:font-light overflow-clip">{summary}</p>
            </div>
        </div>

        <div class="flex-none">
            {#if article.image}
                <img src={article.image} alt={article.title} class="w-full h-full object-cover sm:rounded-sm !h-[140px]" />
            {:else}
                <div class="bg-secondary w-full h-full object-cover sm:rounded-sm !h-[140px]" />
            {/if}
        </div>
    </div>
</a>
</Swipe>