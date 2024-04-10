<script lang="ts">
	import { getDefaultRelaySet } from "$utils/ndk";
	import { Textarea, ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NostrEvent, getRootEventId, isEventOriginalPost } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let reply: NDKEvent = new NDKEvent($ndk, { kind: NDKKind.GroupReply } as NostrEvent);
    export let showReply = true;

    if (event.kind === NDKKind.Text) {
        reply.kind = NDKKind.Text;
    }

    let publishing = false;

    async function publish() {
        publishing = true;
        reply.tag(event, "reply");
        const hTag = event.tagValue("h");
        if (hTag) { reply.tags.push(["h", hTag]); }

        let rootEventId = getRootEventId(event);
        if (!rootEventId && isEventOriginalPost(event)) rootEventId = event.id;
        if (rootEventId) reply.tags.push(["e", rootEventId, "", "root"]);

        try {
            await reply.publish(getDefaultRelaySet());
            reply = new NDKEvent($ndk, { kind: NDKKind.GroupReply } as NostrEvent);
            showReply = false;
        } finally {
            publishing = false;
        }
    }
</script>

<div class="relative w-full bg-white/5">
    <Textarea
        bind:value={reply.content}
        placeholder="Reply..."
        class="!rounded-none !border-0 w-full !bg-transparent p-4 pb-14"
    />
    <div class="absolute bottom-4 left-4 flex flex-row gap-6">
        <button class="button px-6" on:click={publish}>
            {#if publishing}
                Publishing...
            {:else}
                Reply
            {/if}
        </button>

        <button class="" on:click={() => showReply = false}>
            Cancel
        </button>
    </div>
</div>