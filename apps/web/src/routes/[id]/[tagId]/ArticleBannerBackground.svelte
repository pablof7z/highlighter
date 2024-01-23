<script lang="ts">
	import type { NDKArticle } from "@nostr-dev-kit/ndk";

    export let article: NDKArticle;
</script>

{#if article.image}
    <div class=" left-0 right-0 max-h-[80vh] fixed overflow-hidden opacity-20 -z-10">
        <img class="w-full relative sm:rounded-xl object-cover object-top h-full" src={article.image} />
        <div class="absolute bottom-0 w-full h-4/5 bg-gradient-to-b from-transparent to-black"></div>
    </div>
{/if}