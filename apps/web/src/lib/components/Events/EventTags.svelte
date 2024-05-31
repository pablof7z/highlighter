<script lang="ts">
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import Tags from "./Tags.svelte";

    export let event: NDKEvent;

    const tags = Array.from(new Set(event.getMatchingTags("t").map(t => t[1])));
</script>

<Tags {tags} />
