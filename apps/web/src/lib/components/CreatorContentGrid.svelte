<script lang="ts">
	import { NDKKind, type NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";

    export let content: Readable<NDKEvent[]>;

    let articles = derived(content, $content => {
        return $content
            .filter((event: NDKEvent) => event.kind === NDKKind.Article)
            .map((event: NDKEvent) => NDKArticle.from(event));
    })
</script>

