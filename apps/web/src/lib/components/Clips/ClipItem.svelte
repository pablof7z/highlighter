<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "@kind0/ui-common";
    import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
</script>

<EventWrapper {event} class="border border-base-200 p-6 rounded-box {$$props.class??""}">
    <EventContent ndk={$ndk} event={event} class="prose highlight" />
</EventWrapper>