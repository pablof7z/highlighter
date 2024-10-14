<script lang="ts">
	import { getSummary } from "$utils/article";
	import { NDKArticle, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import ContentHeader from "$components/Content/Header.svelte";
	import { layout } from "$stores/layout";
	import { getEventUrl } from "$utils/url";
	import { onDestroy, onMount } from "svelte";

    export let article: NDKArticle;
    export let skipImage = false;
    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    let mainView: string;
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