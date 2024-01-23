<script lang="ts">
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { ArrowLeft, CaretLeft } from "phosphor-svelte";

    export let urlPrefix: string;
    export let eventTitle: string;
    export let title: string;
</script>

<h1 class="text-xl font-semibold text-white text-center w-full pt-4 flex flex-row items-center justify-between gap-6 overflow-hidden">
    <span class="flex flex-row gap-2 items-center">
        <a href={urlPrefix}>
            <ArrowLeft class="w-6 h-6 max-sm:hidden" />
            <CaretLeft class="w-6 h-6 sm:hidden" />
        </a>
        {title}
    </span>

    <span class="truncate font-normal opacity-60 whitespace-nowrap max-sm:hidden">
        {eventTitle}
    </span>
</h1>