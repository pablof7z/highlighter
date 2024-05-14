<script lang="ts">
    import { ndk } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKList } from "@nostr-dev-kit/ndk";
	import ItemLink from "./Events/ItemLink.svelte";
	import UserProfile from "./User/UserProfile.svelte";

    export let list: NDKList;
    export let grid: boolean;
    export let skipAuthor: boolean | undefined = undefined;

    const durationTag = `${list.items.length} items`;

    const itemsFilter = list.filterForItems();

    const items = $ndk.storeSubscribe(itemsFilter, {
        groupable: true,
        autoStart: true,
        cacheUsage: NDKSubscriptionCacheUsage.PARALLEL
    });
</script>

<UserProfile user={list.author} let:authorUrl>
    <ItemLink
        event={list}
        {durationTag}
        image={list.tagValue("image")}
        title={list.title}
        {grid}
        useProfileAsDefaultImage={false}
        {skipAuthor}
    >
        {#if !grid}
            <ul class="overflow-clip self-stretch max-h-24">
                {#each $items as item}
                    <li class="py-1 truncate">
                        <a
                            href="{authorUrl}/{list.dTag}/{item.dTag}"
                            class="text-neutral-500"
                        >
                            {item.tagValue("title")}
                        </a>
                    </li>
                {/each}
            </ul>
        {/if}
    </ItemLink>
</UserProfile>