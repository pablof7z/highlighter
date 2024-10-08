<script lang="ts">
	import LayoutHeader from './LayoutHeader.svelte';
	import { getSummary } from "$utils/article";
	import { NDKArticle, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import ContentHeader from "$components/Content/Header.svelte";
	import { layout } from "$stores/layout";
	import Footer from "./Footer.svelte";
	import { getEventUrl } from "$utils/url";
	import { page } from "$app/stores";
	import { addHistory } from "$stores/history";
	import { onDestroy, onMount } from "svelte";

    export let article: NDKArticle;
    export let skipImage = false;
    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    const title = article.title;

    onMount(() => {
        if (title) addHistory({ category: "Read", title, url: $page.url.toString() })
    })

    let image: string | undefined;
    let mainView: string;

    if (!isPreview) {
        $layout.sidebar = false;

        $layout.footer = {
            component: Footer,
            props: { article }
        }
        $layout.navigation = false;
        $layout.fullWidth = false
        $layout.forceShowNavigation = undefined;
    }

    $: if ($layout.footer?.props) $layout.footer!.props.forceMainView = mainView;

    $: image = article.image
    if (!image && !isPreview) image ??= userProfile?.image;

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

    onDestroy(() => {
        $layout.event = undefined;
        $layout.footer = undefined;
    })
</script>

<ContentHeader
    event={article}
    image={article.image}
    summary={getSummary(article)}
    title={article.title}
    {userProfile}
    {authorUrl}
    {isPreview}
    navOptions={
        [{ name: "Article", href: getEventUrl(article, authorUrl) },]
    }
    on:curate={() => mainView = "curation"}
/>