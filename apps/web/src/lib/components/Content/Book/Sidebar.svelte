<script lang="ts">
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    export let chapters: NDKArticle[] = [];
</script>

chapters = {chapters.length}

{#each chapters as chapter}
    <a href="#{chapter.id}" class="block py-2 px-4 text-sm text-gray-500 hover:text-gray-900">
        {chapter.title}
    </a>
{/each}