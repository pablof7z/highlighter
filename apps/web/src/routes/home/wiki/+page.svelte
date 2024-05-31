<script lang="ts">
	import { userFollows } from "$stores/session";
	import { derived } from "svelte/store";
	import { ndk } from "@kind0/ui-common";
	import { onDestroy } from "svelte";
	import { Card } from "konsta/svelte";

    const feed = $ndk.storeSubscribe(
        { kinds: [30818 as number], authors: Array.from($userFollows) }
    );

    onDestroy(() => {
        feed.unsubscribe()
    })

    const categories = derived(feed, $feed => {
        const categories = new Set<string>();

        for (const event of $feed) {
            const category = event.tagValue("c");
            if (category) {
                categories.add(category);
            }
        }

        return Array.from(categories);
    });

    const topics = derived(feed, $feed => {
        const topics = new Set<string>();

        for (const event of $feed) {
            const topic = event.tagValue("d");
            if (topic) topics.add(topic);
        }

        return Array.from(topics);
    });
</script>

<!-- auto grid -->
<div class="flex flex-row flex-wrap">
    {#each $topics as topic}
        <Card class="w-fit">
            <h2>{topic}</h2>
        </Card>
    {/each}
</div>