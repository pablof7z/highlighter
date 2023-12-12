<script lang="ts">
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import type NDK from "@nostr-dev-kit/ndk";

    export let article: NDKArticle;
    let summary: string | undefined;
</script>

<div class="card card-compact lg:card-side bg-base-100 text-white">
    {#if article?.image}
        <figure class="flex-none w-1/4"><img class="h-full" src={article?.image} alt="Album"/></figure>
    {/if}
    <div class="card-body !py-0 overflow-hidden">
        <h2 class="card-title truncate">{article?.title}</h2>
        <p class="text-sm text-white/50">{summary}</p>
    </div>
</div>