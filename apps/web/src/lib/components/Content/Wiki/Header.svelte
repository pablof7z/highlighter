<script lang="ts">
	import { getSummary } from "$utils/article";
	import { NDKArticle, NDKKind, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import ContentHeader from "$components/Content/Header.svelte";
	import { layout } from "$stores/layout";
	import Footer from "$components/Content/Article/Footer.svelte"
	import { getEventUrl } from "$utils/url";
	import { page } from "$app/stores";
	import { addHistory } from "$stores/history";
	import { onDestroy, onMount } from "svelte";
	import { NavigationOption } from "../../../../app";
	import { ndk } from "$stores/ndk";

    export let article: NDKArticle;
    export let skipImage = false;
    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    const title = article.title;

    onMount(() => {
        if (title) addHistory({ category: "Wiki", title, url: $page.url.toString() })
    })

    let image: string | undefined;
    let mainView: string;

    if (!isPreview) {
        $layout.sidebar = false;

        $layout.footer = {
            component: Footer,
            props: { article }
        }
        $layout.footerInMain = true;
        $layout.fullWidth = false
        $layout.title = article.title;
        $layout.header = undefined;

        onDestroy(() => { $layout.footerInMain = undefined; })
    }

    $: if ($layout.footer?.props) $layout.footer!.props.forceMainView = mainView;

    $: image = article.image
    if (!image && !isPreview) image ??= userProfile?.image;

    $: if (!isPreview) {
        if (article.title) $layout.title = article.title;
        $layout.event = article;
        $layout.header = undefined;
    }

    onDestroy(() => {
        $layout.event = undefined;
    })

    let navOptions: NavigationOption[] = [
        { name: "Wiki", href: getEventUrl(article, authorUrl) },
        { name: "Chat", href: getEventUrl(article, authorUrl, 'chat') }
    ]

    const otherEntries = $ndk.storeSubscribe({
        kinds: [NDKKind.Wiki], "#d": [article.dTag!]
    }, {  groupable: false, closeOnEose: true, onEose: () => {
        if ($otherEntries.length > 1) {
            navOptions.push({ name: "Other Entries", badge: $otherEntries.length.toString(), href: getEventUrl(article, authorUrl, "similar") });
            navOptions = navOptions;
        }
    }})
    
</script>

<ContentHeader
    event={article}
    image={article.image}
    summary={getSummary(article)}
    title={article.title}
    skipEmptyZaps={true}
    {userProfile}
    {authorUrl}
    {isPreview}
    {navOptions}
    on:curate={() => mainView = "curation"}
/>