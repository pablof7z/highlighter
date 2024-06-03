<script lang="ts">
	import { NDKHighlight, type NDKEvent } from "@nostr-dev-kit/ndk";
	import EventWrapper from "./Feed/EventWrapper.svelte";
	import HighlightBody from "./HighlightBody.svelte";
	import { ndk } from "$stores/ndk.js";
    import { removeQuotedEvent } from "$utils/highlight";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let note: NDKEvent;
    export let quotedHighlight: NDKHighlight | undefined = undefined;

    if (!quotedHighlight) {
        const qTag = note.tagValue("q");

        if (qTag) {
            $ndk.fetchEvent(qTag).then(event => {
                if (event) {
                    quotedHighlight = NDKHighlight.from(event)
                }
            });
        }
    }

    const noteWithoutEmbed = removeQuotedEvent(note);
</script>

{#if quotedHighlight}
    <EventWrapper event={note} reverse={true} class={$$props.class??""}>
        <div class="pl-12 flex flex-col gap-4">
            <HighlightBody highlight={quotedHighlight} class="leading-5" />

            <EventContent ndk={$ndk} event={note} content={noteWithoutEmbed} class="leading-8 text-white" />
        </div>
    </EventWrapper>
{/if}