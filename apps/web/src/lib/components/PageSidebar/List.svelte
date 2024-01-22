<script lang="ts">
	import { RelativeTime, ndk } from '@kind0/ui-common';
	import PageSidebar from "$components/PageSidebar.svelte";
	import { NDKArticle, type NDKList } from "@nostr-dev-kit/ndk";
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import FeedArticle from '$components/Feed/FeedArticle.svelte';
	import Article from '$components/List/Article.svelte';
	import { page } from '$app/stores';
	import ListViewContent from '$components/ListViewContent.svelte';
    let open = true;

    export let list: NDKList;
    export let urlPrefix: string;

    const listTitle = list.title || "List";
    const listImage = list.tagValue("image");

    const filters = list.filterForItems();
    const items = $ndk.storeSubscribe(filters);

    let selectedItemId: string | undefined = undefined;

    $: selectedItemId = $page.params.subId;

    // const items = ;
</script>

<svelte:head>
    <title>{listTitle}</title>
</svelte:head>

<PageSidebar title={listTitle} bind:open innerClass="!px-0 !gap-0">
    <ListViewContent {list} {urlPrefix} />
</PageSidebar>

<style lang="postcss">
    .tab {
        @apply text-[15px] text-opacity-60 leading-5 font-semibold;
    }

    .tab-active {
        @apply !text-accent2;
    }
</style>