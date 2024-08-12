<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKArticle, NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";
	import { writable } from "svelte/store";
    import * as Feed from "$components/Feed";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";

    export let event: NDKEvent;

    const events = writable<NDKArticle[]>([]);

    try {
        const list = JSON.parse(event.content);
        console.log(list);
        for (const listItem of list) {
            console.log(listItem);
            $ndk.fetchEventFromTag(listItem as NDKTag, event)
                .then((e) => {
                    if (e) events.update((prev) => [...prev, NDKArticle.from(e)]);
                });
        }
    } catch (e) {
        console.error(e);
    }
</script>

<h1>
    <AvatarWithName user={event.author} />
</h1>

<Feed.Articles
    store={events}
/>