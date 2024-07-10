<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
</script>

<EventWrapper {event} />