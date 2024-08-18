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
	import { eventIsInGroup } from "$utils/preview";
	import EventTags from "$components/Events/EventTags.svelte";

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
                    <AvatarWithName user={article.author} avatarSize="small" class="font-light !text-xs truncate" />
                {/if}
            </div>
        </div>

        <div class="flex flex-row items-center gap-2 justify-end">
            <Badge variant="secondary" class="font-light text-muted-foreground">
                <RelativeTime event={article} />
            </Badge>

            <Badge variant="secondary" class="font-light text-muted-foreground whitespace-nowrap">
                {time}
            </Badge>
        </div>

        <div class="col-span-2 flex flex-col">
            <div class="flex flex-col gap-0">
                <h2 class="text-xl md:text-xl font-medium mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{article.title}</h2>
                <p class="text-base text-muted-foreground max-h-[3.5rem] sm:font-light overflow-clip">{summary}</p>
            </div>
        </div>

        <div class="flex-none">
            {#if article.image}
                <img src={article.image} alt={article.title} class="w-full h-full object-cover sm:rounded-sm" />
            {/if}
        </div>
        
        <div class="col-span-3 mt-1 flex flex-col gap-1">
            <RelatedEvents event={article} />
            <EventTags event={article} />
        </div>
    </div>
</a>
</Swipe>