<script lang="ts">
	import ArticleCard from '$components/ArticleCard.svelte';
	import { NDKHighlight } from '@nostr-dev-kit/ndk';

    export let url: string;
    export let highlights: NDKHighlight[] = [];

    let doc: any;

    fetch(`https://nostr.api.v0l.io/api/v1/preview?url=${url}`)
        .then(res => res.json()
        .then(data => doc = data));

    let href = `/load?url=${encodeURIComponent(url)}`
    let siteName = new URL(url).hostname;

    $: if (doc?.og_tags?.find(tag => tag[0] === 'og:site_name')) {
        let s = doc.og_tags.find(tag => tag[0] === 'og:site_name')[1];
        if (s) siteName = s;
    }
</script>

{#if doc && doc.title && doc.image}
    <ArticleCard
        title={doc.title}
        image={doc.image}
        description={doc.description}
        href={href}
        author={siteName}
        {highlights}
    />
{/if}