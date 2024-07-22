<script lang="ts">
	import { NDKList, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk.js";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";
	import FeaturedContentCard from "./FeaturedContentCard.svelte";

    export let list: NDKList | undefined = undefined;

    let url: string;
    let authorUrl: string;
    
    $: if (list) {
        const suffix = urlSuffixFromEvent(list);
        if (authorUrl && suffix.length > 0)
            url = [authorUrl, suffix].join('/')
        else
            url = `a/${list.encode()}`
    }
</script>

{#if list}
    <FeaturedContentCard
        event={list}
        title={list.title??"Untitled"}
        image={list.image}
        description={list.description}
        author={list.author}
        href={urlFromEvent(list)}
        {...$$props}
    />
{/if}