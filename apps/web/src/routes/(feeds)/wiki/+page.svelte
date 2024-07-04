<script lang="ts">
	import { userFollows } from "$stores/session";
	import { derived } from "svelte/store";
	import { ndk } from "$stores/ndk.js";
	import { onDestroy } from "svelte";
    import HorizontalList from "$components/PageElements/HorizontalList";
	import { Card } from "konsta/svelte";
	import Scroll from "quill/blots/scroll";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import EventTags from "$components/Events/EventTags.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";

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

<HorizontalList title="Recently Edited" items={$feed} let:item>
    <a href="/a/{item.encode()}" class="rounded-xl bg-secondary p-4 flex flex-col gap-4 w-full">
        <div class="text-lg font-bold truncate">{item.tagValue("title")}</div>

        <div class="flex flex-row gap-4 items-center justify-between">
            <AvatarWithName pubkey={item.pubkey} avatarSize="small" nameClass="text-muted-foreground text-sm" />

            <RelativeTime timestamp={item.created_at*1000} class="text-muted-foreground text-sm" />
        </div>
    </a>
</HorizontalList>

<!-- auto grid -->
<div class="flex flex-row flex-wrap">
    {#each $topics as topic}
        <Card class="w-fit">
            <h2>{topic}</h2>
        </Card>
    {/each}
</div>