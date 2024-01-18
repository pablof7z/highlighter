<script lang="ts">
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { ArrowLeft } from "phosphor-svelte";

    export let urlPrefix: string;
    export let article: NDKArticle;
    export let title: string;
</script>

<h1 class="text-xl font-semibold text-white text-center w-full pt-4 flex flex-row items-center justify-between gap-6">
    <span class="flex flex-row gap-2 items-center">
        <a href={urlPrefix}>
            <ArrowLeft class="w-6 h-6" />
        </a>
        {title}
    </span>

    <span class="truncate font-normal opacity-60 whitespace-nowrap">
        {article.title}
    </span>
</h1>