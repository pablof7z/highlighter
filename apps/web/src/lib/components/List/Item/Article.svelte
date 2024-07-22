<script lang="ts">
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    export let article: NDKArticle;

    let image = article.image;
    image ??= `https://picsum.photos/200/200?random=${Math.floor(Math.random() * 1000)}`;
</script>

<div class="flex flex-col gap-2">
    <div class="flex flex-row gap-2 items-start">
        <img src={image} alt={article.title} class="object-cover w-24 h-24" />
    
        <div class="flex flex-col gap-0">
            <div class="text-lg font-bold max-h-[3.5rem] overflow-clip font-[InterDisplay]">{article.title}</div>
        </div>
    </div>

    {#if article.summary}
            <div class="text-muted-foreground text-sm">{article.summary}</div>
        {/if}
</div>