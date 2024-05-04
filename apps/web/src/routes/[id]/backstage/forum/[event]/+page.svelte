<script lang="ts">
	import { page } from "$app/stores";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    let event: string;

    $: {
        event = $page.params.event;
        $ndk.fetchEvent(event).then((ev) => {
            e = ev;
        });
    }

    let e: NDKEvent | null;

    
</script>

{#if e}
    <div class="discussion-wrapper max-w-3xl mx-auto w-full">
        <EventWrapper
            event={e}
            expandThread={true}
            class="text-lg"
        />
    </div>
{/if}