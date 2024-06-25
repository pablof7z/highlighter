<script lang="ts">
    import { ndk } from "$stores/ndk.js";
	import { NDKEvent, NDKSubscriptionCacheUsage, type NDKList } from "@nostr-dev-kit/ndk";
	import ItemLink from "./Events/ItemLink.svelte";
	import UserProfile from "./User/UserProfile.svelte";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";

    export let list: NDKList;
    export let grid: boolean;
    export let skipAuthor: boolean | undefined = undefined;

    let items: NDKEventStore<NDKEvent>;

    const durationTag = `${list.items.length} items`;

    const itemsFilter = list.filterForItems();

    if (itemsFilter[0] && Object.keys(itemsFilter[0]).length > 0) {
        items = $ndk.storeSubscribe(itemsFilter, {
            groupable: true,
            autoStart: true,
            cacheUsage: NDKSubscriptionCacheUsage.PARALLEL
        });
    }
</script>

{#if $items}
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
{/if}