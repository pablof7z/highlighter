<script lang="ts">
	import HorizontalList from "$components/PageElements/HorizontalList";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKWiki } from "@nostr-dev-kit/ndk";
	import { Card } from "konsta/svelte";
	import { derived, Readable } from "svelte/store";

    export let store: Readable<NDKWiki[]>;

    const categories = derived(store, $store => {
        const categories = new Set<string>();

        for (const event of $store) {
            const category = event.tagValue("c");
            if (category) {
                categories.add(category);
            }
        }

        return Array.from(categories);
    });

    const topics = derived(store, $store => {
        const topics = new Set<string>();

        for (const event of $store) {
            const topic = event.tagValue("d");
            if (topic) topics.add(topic);
        }

        return Array.from(topics);
    });

    const featuredCategories = derived([categories, store], ([$categories, $store]) => {
        const articlesPerCategory = new Map<string, number>();

        for (const event of $store) {
            const category = event.tagValue("c");
            if (category) {
                articlesPerCategory.set(category, (articlesPerCategory.get(category) || 0) + 1);
            } else {
                articlesPerCategory.set("Uncategorized", (articlesPerCategory.get("Uncategorized") || 0) + 1);
            }
        }

        return $categories
            .filter(category => articlesPerCategory.get(category) >= 3)
            .sort((a, b) => {
                const aCount = articlesPerCategory.get(a) || 0;
                const bCount = articlesPerCategory.get(b) || 0;
                return bCount - aCount;
            })
            .slice(0, 10);
    });
</script>

<HorizontalList title="Recently Edited" items={$store} let:item>
    <a href="/a/{item.encode()}" class="rounded-xl bg-secondary p-4 flex flex-col gap-4 w-full">
        <div class="text-lg font-bold truncate">{item.tagValue("title")}</div>

        <div class="flex flex-row gap-4 items-center justify-between">
            <AvatarWithName pubkey={item.pubkey} avatarSize="small" nameClass="text-muted-foreground text-sm" />

            <RelativeTime timestamp={item.created_at*1000} class="text-muted-foreground text-sm" />
        </div>
    </a>
</HorizontalList>

{#each $featuredCategories as category}
    <HorizontalList title={category} items={$store.filter(event => event.tagValue("c") === category)} let:item>
        <a href="/a/{item.encode()}" class="rounded-xl bg-secondary p-4 flex flex-col gap-4 w-full">
            <div class="text-lg font-bold truncate">{item.tagValue("title")}</div>

            <div class="flex flex-row gap-4 items-center justify-between">
                <AvatarWithName pubkey={item.pubkey} avatarSize="small" nameClass="text-muted-foreground text-sm" />

                <RelativeTime timestamp={item.created_at*1000} class="text-muted-foreground text-sm" />
            </div>
        </a>
    </HorizontalList>
{/each}

<!-- auto grid -->
<div class="flex flex-row flex-wrap">
    {#each $topics as topic}
        <Card class="w-fit">
            <h2>{topic}</h2>
        </Card>
    {/each}
</div>