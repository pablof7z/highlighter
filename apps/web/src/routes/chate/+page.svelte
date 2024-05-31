<script lang="ts">
	import ChatInput from '$components/Chat/Input.svelte';
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import { pageHeader } from "$stores/layout";
	import { userFollows } from "$stores/session";
	import { ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
	import { goto } from '$app/navigation';

    const feed = $ndk.storeSubscribe(
        { kinds: [1], authors: Array.from($userFollows), limit: 50},
        { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY }
    );

    const onlyOp = derived(feed, ($feed) => {
        return $feed.filter((e: NDKEvent) => !e.tagValue("e"));
    })

    $pageHeader = {
        footer: {
            component: ChatInput,
            props: { tags: [], kind: 1, placeholder: "What's going on?!" }
        }
    }
</script>

<div class="flex flex-col grow justify-end gap-6 overflow-y-auto scrollable-content relative">
    {#each $onlyOp as event (event.id)}
        <ChatBubble {event} on:click={() => goto(`/chate/${event.encode()}`)} />
    {/each}
</div>