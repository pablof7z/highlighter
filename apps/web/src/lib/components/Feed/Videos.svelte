<script lang="ts">
	import { NDKVideo } from "@nostr-dev-kit/ndk";
	import { derived, Readable } from "svelte/store";
    import * as Card from '$components/Card';

    export let store: Readable<NDKVideo[]>;
    export let featuredItems = derived(store, $store => {
        return $store.slice(0, 1);
    });

    export let skipAuthor = false;
    export let gridSetup = "lg:grid-cols-2";

    const featuredItemIds = derived(featuredItems, $featuredItems => {
        return $featuredItems.map(item => item.id);
    });


</script>

<!-- {#if $featuredItems.length > 0}
    <div class="flex flex-col gap-6 border-b border-border pb-[var(--section-vertical-padding)]">
        {#each $featuredItems as video}
            <Card.FeaturedArticle {video} {skipAuthor} />
        {/each}
    </div>
{/if} -->

<div class="lg:grid {gridSetup} gap-6 flex flex-col flex-wrap max-lg:divide-y divide-border">
    {#each $store as video}
        {#if !$featuredItemIds.includes(video.id)}
            <div class="py-[var(--section-vertical-padding)] w-full">
                <Card.Video
                    {video}
                    {skipAuthor}
                    width="w-full"
                    inContentFeed
                />
            </div>
        {/if}
    {/each}
</div>