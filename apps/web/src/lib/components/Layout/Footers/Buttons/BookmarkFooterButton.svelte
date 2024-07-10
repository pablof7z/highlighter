<script lang="ts">
	import { toggleBookmarkedEvent } from "$lib/events/bookmark";
	import { userGenericCuration } from "$stores/session";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Button } from "$components/ui/button";
	import { BookmarkSimple } from "phosphor-svelte";

    export let event: NDKEvent;

    const eventReferenceTag = event.tagId()

    let saved;

    $: saved = $userGenericCuration.has(eventReferenceTag);
</script>

<Button
    variant="outline"
    class="footer-button flex flex-col items-center gap-2 h-auto text-lg bg-opacity-50 p-4"
    on:click={() => toggleBookmarkedEvent(event)}
>
    {#if saved}
        <BookmarkSimple size={40} />
    {:else}
        <BookmarkSimple size={40} weight="fill" />
    {/if}
    Bookmark
</Button>

