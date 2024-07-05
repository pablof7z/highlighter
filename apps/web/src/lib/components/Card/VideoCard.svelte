<script lang="ts">
	import { NDKVideo, type NDKTag } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";
	import { ndk } from "$stores/ndk.js";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let video: NDKVideo | undefined = undefined;
    export let tag: NDKTag | undefined = undefined;

    let url: string;
    let authorUrl: string;
    
    if (!video && tag)
        $ndk.fetchEvent(tag[1]).then(event => {
            if (event) {
                video = NDKVideo.from(event);
            }
        });

    $: if (video) {
        const suffix = urlSuffixFromEvent(video);
        if (authorUrl && suffix.length > 0)
            url = [authorUrl, suffix].join('/')
        else
            url = `a/${video.encode()}`
    }
</script>

{#if video}
    <ContentCard
        title={video.title??"Untitled"}
        image={video.thumbnail}
        description={video.content}
        author={video.author}
        href={urlFromEvent(video)}
        {...$$props}
    />
{/if}