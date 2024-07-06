<script lang="ts">
	import { layout, pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { goto } from "$app/navigation";
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import { derived } from "svelte/store";
	import ChatFooter from "./ChatFooter.svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";

    export let group: NDKSimpleGroup;

    const chat = $ndk.storeSubscribe({
        kinds: [NDKKind.GroupChat], "#h": [group.groupId]
    }, { groupable: true, subId: 'group-content', relaySet: group.relaySet });

    const sortedChat = derived(chat, ($chat) => {
        return $chat.sort((a, b) => a.created_at! - b.created_at!);
    });

    onDestroy(() => {
        chat.unsubscribe();
    })

    let tags: NDKTag[] = [ [ "h", group.groupId ] ];

    $layout.footer = {
        component: ChatFooter,
        props: { tags, group, kind: NDKKind.GroupChat, placeholder: "Say something..." }
    }

    $: if ($chat.length > 0) {
        tags = tags.filter((t) => t[0] !== "previous");

        const previous = $chat.slice(0, 10)
            .map(e => e.id.slice(0, 8))
        
        tags.push([ "previous", ...previous ]);

        if ($layout.footer?.props) $layout.footer.props.tags = tags;
    }
</script>

<ScrollArea class="mb-20">
    <div class="flex flex-col">
        {#each $sortedChat as event, i (event.id)}
            <ChatBubble
                {event}
                skipName={$chat[i - 1]?.pubkey === event.pubkey}
                skipAvatar={$chat[i + 1]?.pubkey === event.pubkey}
                skipTime={$chat[i - 1] && $chat[i - 1].created_at > event.created_at - 60}
                on:click={() => goto(`/chate/${event.encode()}`)}
            />
        {/each}
    </div>
</ScrollArea>