<script lang="ts">
	import { NDKArticle, NDKHighlight, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { Readable, writable } from "svelte/store";
    import LayoutHeader from "./LayoutHeader.svelte";
	import Header from "./Header.svelte";
	import { layout } from "$stores/layout";
	import { ArticleSettings, Footer } from ".";
	import { onDestroy, setContext } from "svelte";
	import { getEventUrl } from "$utils/url";
	import { Button } from "$components/ui/button";
	import { ArrowLeft } from "phosphor-svelte";

    export let article: NDKArticle;
    export let isPreview = false;
    export let isItemView = true;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let highlights: Readable<NDKHighlight[]>;

    const settings = writable<ArticleSettings>({
        highlights: {
            byUser: true,
            byNetwork: true,
            outOfNetwork: false,
        }
    });

    setContext('settings', settings);

    if (!isPreview) {
        $layout.sidebar = false;

        $layout.footer = {
            component: Footer,
            props: { article, highlights, settings }
        }
        $layout.navigation = false;
        $layout.fullWidth = false
        $layout.forceShowNavigation = undefined;
    }

    $: image = article.image
    if (!image && !isPreview) image ??= userProfile?.image;

    onDestroy(() => {
        $layout.event = undefined;
        $layout.footer = undefined;
    })

    $: if (!isPreview) {
        if (article.title) $layout.title = article.title;
        $layout.header = {
            component: LayoutHeader,
            props: {
                event: article,
                title: article.title,
            }
        }
    }
</script>

<div class="max-w-[var(--content-focused-width)] mx-auto w-full">
    {#if isItemView}
        <Header 
            article={article}
            {isPreview}
            {userProfile}
            {authorUrl}
        />
    {:else}
        <div class="flex flex-col py-6 items-start">
            <Button size="sm" variant="secondary" href={getEventUrl(article, authorUrl)} class="w-fit text-xs">
                <ArrowLeft size={24} class="mr-2" /> Back to article
            </Button>
        </div>
    {/if}

    <slot />
</div>