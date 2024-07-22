<script lang="ts">
	import { getSummary } from "$utils/article";
	import { NDKArticle, NDKList, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import ContentHeader from "$components/Content/Header.svelte";
	import { layout } from "$stores/layout";
	import TopHeader from "../TopHeader.svelte";
	import { getEventUrl } from "$utils/url";
	import { page } from "$app/stores";
	import { addHistory } from "$stores/history";
	import { title } from "process";
	import { onMount } from "svelte";

    export let list: NDKList;
    export let skipImage = false;
    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let blossom: any | undefined = undefined;

    onMount(() => {
        addHistory({ category: "Curation", title, url: $page.url.toString() })
    })

    let image: string | undefined;

    if (!isPreview) {
        $layout.sidebar = false;
    }

    $: image = list.image
    if (!image && !isPreview) image ??= userProfile?.image;

    $: if (!isPreview) {
        $layout.header = {
            component: TopHeader,
            props: { event: list, userProfile, authorUrl }
        }
        if (list.title) $layout.title = list.title;
    }
</script>


<ContentHeader
    event={list}
    image={list.image}
    summary={list.description}
    title={list.title}
    {userProfile}
    {authorUrl}
    {isPreview}
    navOptions={
        [{ name: "List", href: getEventUrl(list, authorUrl) },]
    }
/>
