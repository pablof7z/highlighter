<script lang="ts">
	import type { NDKDVMJobFeedback } from "@nostr-dev-kit/ndk";
    import ndk from "$stores/ndk";
	import JobStatusLabel from "./JobStatusLabel.svelte";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import Time from "svelte-time/src/Time.svelte";
	import { onMount } from "svelte";
	import { markEventAsSeen } from "$stores/notifications";

    export let event: NDKDVMJobFeedback;
    export let dontMarkAsSeen: boolean = false;

    const status = event.tagValue("status");

    function contentIsImageUrl() {
        try {
            const url = new URL(event.content);

            return url.pathname.endsWith(".png") ||
                url.pathname.endsWith(".jpg") ||
                url.pathname.endsWith(".jpeg");
        } catch (e) {
            return false;
        }
    }

    const timestamp = event.created_at!*1000;

    function useRelativeTime() {
        const now = Date.now();
        const diff = now - timestamp;

        return diff < 1000*60*60*24;
    }

    onMount(() => {
        if (!dontMarkAsSeen) markEventAsSeen(event.id);
    })
</script>

<div class="
    flex flex-row w-full items-center whitespace-normal
    {event.kind >= 6000 && event.kind < 7000 ? "text-lg" : ""}
">
    <div class="flex-grow overflow-y-auto overflow-x-clip
        {contentIsImageUrl() ? "" : "max-h-48"}
    ">
        {#if (event.kind >= 6000 && event.kind < 7000) && contentIsImageUrl()}
            <img src={event.content} class="max-h-96" />
        {/if}
        <EventContent ndk={$ndk} {event} showMedia={true} />
    </div>
    <div class="w-1/5 self-end text-right">
        <a href="https://nostr.com/{event.encode()}">
            <Time
                live={true}
                relative={useRelativeTime()}
                {timestamp}
                class="text-xs font-normal my-0.5 block opacity-50 whitespace-nowrap"
            />
            <JobStatusLabel {status} {event} />
        </a>
    </div>
</div>