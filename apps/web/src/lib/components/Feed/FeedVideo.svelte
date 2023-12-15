<script lang="ts">
	import type { NDKVideo } from '@nostr-dev-kit/ndk';
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "@kind0/ui-common";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { randomVideoThumbnail } from '$utils/skeleton';

    export let video: NDKVideo;

    const summary = video.summary || video.content.slice(0, 100);

    let thumbnail = video.thumbnail;

    thumbnail ??= randomVideoThumbnail();
</script>

<EventWrapper event={video}>
    {#if thumbnail}
        <img src={thumbnail} alt={video.title} class="w-full h-96 object-cover rounded-t-lg object-top" />
    {/if}

    <div class="flex flex-col gap-1 w-full">
        <div class="text-white text-lg">
            {video.title}
        </div>

        <EventContent ndk={$ndk} event={video} content={summary} />
    </div>
</EventWrapper>