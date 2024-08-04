<script lang="ts">
	import { NDKArticle, NDKList, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import ContentHeader from "$components/Content/Header.svelte";
	import { layout } from "$stores/layout";
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
        if (list.title) $layout.title = list.title;
        $layout.event = list;
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
