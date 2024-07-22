<script lang="ts">
	import { NDKList, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";
	import { ndk } from "$stores/ndk.js";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let list: NDKList | undefined = undefined;
    export let tag: NDKTag | undefined = undefined;

    let url: string;
    let authorUrl: string;
    
    if (!list && tag)
        $ndk.fetchEvent(tag[1]).then(event => {
            if (event) {
                list = NDKArticle.from(event);
            }
        });

    $: if (list) {
        const suffix = urlSuffixFromEvent(list);
        if (authorUrl && suffix.length > 0)
            url = [authorUrl, suffix].join('/')
        else
            url = `a/${list.encode()}`
    }
</script>

{#if list}
    <ContentCard
        title={list.title??"Untitled"}
        image={list.image}
        description={list.description}
        author={list.author}
        href={urlFromEvent(list)}
        {...$$props}
    />
{/if}