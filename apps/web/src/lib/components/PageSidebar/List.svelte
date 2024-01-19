<script lang="ts">
	import { RelativeTime, ndk } from '@kind0/ui-common';
	import PageSidebar from "$components/PageSidebar.svelte";
	import { NDKArticle, type NDKList } from "@nostr-dev-kit/ndk";
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import FeedArticle from '$components/Feed/FeedArticle.svelte';
	import Article from '$components/List/Article.svelte';
    let open = true;

    export let list: NDKList;

    const listTitle = list.title || "List";

    const filters = list.filterForItems();
    const items = $ndk.storeSubscribe(filters);

    // const items = ;
</script>

<svelte:head>
    <title>{listTitle}</title>
</svelte:head>

<PageSidebar title={listTitle} bind:open>
    {#if list.content.length > 0}
        <div class="prose">
            {list.content}
        </div>
    {/if}

    <div class="flex flex-row items-center w-full justify-between">
        <AvatarWithName
            user={list.author}
            avatarSize="small"
        />

        <RelativeTime event={list} class="text-neutral-500 text-sm" />
    </div>

    {#each $items as item}
        <Article article={NDKArticle.from(item)} />
    {/each}
</PageSidebar>

<style lang="postcss">
    .tab {
        @apply text-[15px] text-opacity-60 leading-5 font-semibold;
    }

    .tab-active {
        @apply !text-accent2;
    }
</style>