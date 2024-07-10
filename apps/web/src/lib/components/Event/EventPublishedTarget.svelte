<script lang="ts">
	import Badge from "$components/ui/badge/badge.svelte";
import { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;

    const hTags: NDKTag[] = event.getMatchingTags("h");
</script>

{#if hTags === 0}
{/if}