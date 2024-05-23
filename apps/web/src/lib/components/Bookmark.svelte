<script lang="ts">
	import { toggleBookmarkedEvent } from "$lib/events/bookmark";
	import { userGenericCuration } from "$stores/session";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import BookmarkButton from "./buttons/BookmarkButton.svelte";

    export let event: NDKEvent;

    const eventReferenceTag = event.tagId()

    let saved;

    $: saved = $userGenericCuration.has(eventReferenceTag);
</script>

<BookmarkButton
    active={saved}
    on:click={() => toggleBookmarkedEvent(event)}
/>
