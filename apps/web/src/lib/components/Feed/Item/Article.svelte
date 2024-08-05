<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import RelatedEvents from "./RelatedEvents.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { getSummary, readTime } from "$utils/article";
	import Swipe from "$components/Swipe.svelte";
	import { NavigationOption } from "../../../../app";
	import { BookmarkSimple } from "phosphor-svelte";
	import { toast } from "svelte-sonner";
    import { saveForLater } from "$lib/actions/Events/save-for-later.js";
	import { appMobileView } from "$stores/app";

    export let article: NDKArticle;
    export let skipAuthor = false;
    export let href: string | undefined = undefined;
    export let index: number | undefined = undefined;

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
    <div class="flex flex-row gap-4 ">
        <div class="w-1/3 flex-none">
            {#if article.image}
                <img src={article.image} alt={article.title} class="w-full h-full object-cover rounded-sm" />
            {/if}
        </div>

        <div class="w-2/3 flex flex-col">
            <h2 class="text-lg font-bold mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{article.title}</h2>
            <div class="flex flex-row gap-4 text-muted-foreground lg:text-xs text-sm w-full items-center">
                {#if !skipAuthor}
                    <AvatarWithName user={article.author} avatarSize="tiny" />
                {/if}

                <Badge variant="secondary" class="font-normal text-muted-foreground">
                    <RelativeTime event={article} />
                </Badge>

                <Badge variant="secondary" class="font-normal text-muted-foreground">
                    {time}
                </Badge>
            </div>
            <p class="lg:text-sm text-muted-foreground mt-2 max-sm:max-h-[5rem] overflow-clip">{summary}</p>

            {#if !$appMobileView}
                <RelatedEvents event={article} class="mt-4" />
            {/if}
        </div>
    </div>

    {#if $appMobileView}
        <RelatedEvents event={article} />
    {/if}
</a>
</Swipe>