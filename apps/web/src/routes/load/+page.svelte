<script lang="ts">
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';
	import { Badge } from '$components/ui/badge';
    import { page } from '$app/stores';
	import UrlView from '$components/UrlView.svelte';
    import { fetchArticle } from '$lib/article';
	import { layout } from '$stores/layout.js';
    import { NDKUser, type Hexpubkey } from '@nostr-dev-kit/ndk';

    $layout.fullWidth = false;
    $layout.sidebar = false;
    $layout.navigation = false;

    export let data;

    const { feed, text, contentType } = data;

    console.log({data, feed});

    let url: string;
    let author: string;

    $: {
        url = $page.url.searchParams.get('url') || '';
        author = $page.url.searchParams.get('author') || '';

        if (url.startsWith('https://highlighter.com/load?url=')) {
            url = decodeURIComponent(url.replace('https://highlighter.com/load?url=', '') || '');
        }
    }

    let authorHexpubkey: Hexpubkey | undefined;

    $: {
        if (author && authorHexpubkey === undefined) {
            try {
                if (author.startsWith('npub')) {
                    authorHexpubkey = (new NDKUser({npub: author})).hexpubkey;
                } else {
                    authorHexpubkey = author;
                }
            } catch(e) {}
        }
    }
</script>

    {#if contentType === 'text/plain'}
        <!-- <Reader
            article={url}
            content={text.replace(/  /g, ' ')}
            unmarkedContent={text.replace(/  /g, ' ')}
            url={url}
        /> -->
    {:else if contentType === 'embed/overcast'}
        overcast
    {:else if contentType.match(/\/rss/)}
        {#if feed}
            <div class="flex flex-col divide-y">
                <h1>{feed.title}</h1>
                
                {#each feed.items as item}

                <a href="/load?url={encodeURIComponent(item.link)}" class="flex flex-col gap-2 min-h-[5rem] lg:min-h-[10rem] py-[var(--section-vertical-padding)] {$$props.class??""}">
                    <div class="grid grid-cols-3 items-start gap-y-1 gap-x-4">
                        <div class="col-span-2">
                            <div class="flex flex-row gap-4 text-muted-foreground lg:text-xs text-sm w-full items-center justify-between mb-2">
                                {item.creator}
                            </div>
                        </div>
                
                        <div class="flex flex-row items-center gap-2 justify-end">
                            {#if item.isoDate}
                                <Badge variant="secondary" class="font-light text-muted-foreground">
                                    <RelativeTime timestamp={new Date(item.isoDate)} />
                                </Badge>
                            {/if}
                
                            <Badge variant="secondary" class="font-light text-muted-foreground whitespace-nowrap">
                                4m
                            </Badge>
                        </div>
                
                        <div class="col-span-2 flex flex-col">
                            <div class="flex flex-col gap-0">
                                <h2 class="text-xl md:text-xl font-medium mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{item.title}</h2>
                                <p class="text-base text-muted-foreground max-h-[3.5rem] sm:font-light overflow-clip">{item.contentSnippet}</p>
                            </div>
                        </div>
                        
                        <!-- <div class="col-span-3 mt-1 flex flex-col gap-1">
                            <RelatedEvents event={article} />
                            <EventTags event={article} />
                        </div> -->
                    </div>
                </a>
                    
                {/each}
            </div>
        {:else}
            <pre>{JSON.stringify(data)}</pre>
        {/if}
        <!-- <Reader
            renderAsHtml={true}
            article={{
                title,
                url: articleUrl
            }}
            content={text}
            unmarkedContent={text}
            url={articleUrl}
        /> -->
    {:else}
        {#await fetchArticle(text, url, contentType)}
            <div class="card">
                <div class="card-body">
                    Loading {url}
                </div>
            </div>
        {:then article}
            {#if article}
                <UrlView {article} />
                <!-- <Reader
                    renderAsHtml={true}
                    {article}
                    content={article.content||""}
                    unmarkedContent={article.content||""}
                    url={article.url}
                /> -->
            {:else}
                <p>Article not found</p>
            {/if}
        {:catch error}
            <div class="card">
                <div class="card-body">
                    {error.message}
                </div>
            </div>
        {/await}
    {/if}