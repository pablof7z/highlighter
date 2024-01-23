<script lang="ts">
	import { RelativeTime, ndk } from '@kind0/ui-common';
	import { NDKArticle, type NDKList } from "@nostr-dev-kit/ndk";
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import Article from '$components/List/Article.svelte';
	import { page } from '$app/stores';

    export let list: NDKList;
    export let urlPrefix: string;

    const listImage = list.tagValue("image");

    const filters = list.filterForItems();
    const items = $ndk.storeSubscribe(filters);

    let selectedItemId: string | undefined = undefined;

    $: selectedItemId = $page.params.subId;
</script>

<div class="px-4 w-full">
    {#if listImage}
        <img src={listImage} alt={list.title} class="w-full h-auto object-cover rounded-2xl" />
    {/if}

    {#if list.content.length > 0}
        <div class="prose">
            {list.content}
        </div>
    {/if}

    <div class="flex flex-row items-center w-full justify-between pb-5">
        <AvatarWithName
            user={list.author}
            avatarSize="small"
        />

        <RelativeTime event={list} class="text-neutral-500 text-sm" />
    </div>
</div>

<div class="h-full overflow-y-auto flex flex-col">
    {#each $items as item (item.id)}
        <Article
            article={NDKArticle.from(item)}
            class="
                p-4
                {selectedItemId === item.tagValue("d") ? "list-item--active" : undefined}
            "
            href={`${urlPrefix}/${item.tagValue("d")}`}
        />
    {/each}
</div>
