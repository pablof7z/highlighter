<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import RelatedEvents from "./RelatedEvents.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { getSummary, readTime } from "$utils/article";

    export let article: NDKArticle;
    export let skipAuthor = false;
    export let href: string | undefined = undefined;

    const summary = getSummary(article, true);

    $: href = href || `/a/${article.encode()}`;

    const time = readTime(article.content);
</script>

<a {href} class="flex flex-col md:flex-row gap-4 min-h-[5rem] lg:min-h-[10rem]">
    <div class="w-full md:w-1/3 flex-none">
        {#if article.image}
            <img src={article.image} alt={article.title} class="w-full h-full object-cover rounded-sm" />
        {/if}
    </div>

    <div class="md:w-2/3 flex flex-col">
        <h2 class="text-lg font-bold mb-0">{article.title}</h2>
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

        <RelatedEvents event={article} class="mt-4" />
    </div>
</a>