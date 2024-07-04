<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { goto } from "$app/navigation";
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import { derived } from "svelte/store";
	import ChatFooter from "./ChatFooter.svelte";

    export let group: NDKSimpleGroup;
    export let href: string;

    $: if ($pageHeader) {
        $pageHeader.footer = {
            component: ChatFooter,
            props: { tags, group, kind: NDKKind.GroupChat, placeholder: "What's going on?!" }
        }
    }

    const chat = $ndk.storeSubscribe({
        kinds: [NDKKind.GroupChat], "#h": [group.groupId]
    }, { groupable: true, subId: 'group-content', relaySet: group.relaySet });

    const onlyOp = derived(chat, ($chat) => {
        return $chat.filter((e: NDKEvent) => !e.tagValue("e"));
    })

    onDestroy(() => {
        chat.unsubscribe();
    })

    let tags: NDKTag[] = [ [ "h", group.groupId ] ];

    $: if ($chat.length > 0) {
        tags = tags.filter((t) => t[0] !== "previous");

        const previous = $chat.slice(0, 10)
            .map(e => e.id.slice(0, 8))
        
        tags.push([ "previous", ...previous ]);
    }
</script>

{group.relaySet.relayUrls}

<div class="flex flex-col grow justify-end gap-2 overflow-y-auto scrollable-content relative mb-20">
    {#each $onlyOp as event,i  (event.id)}
        <ChatBubble
            {event}
            skipAuthor={$onlyOp[i + 1]?.pubkey === event.pubkey}
            on:click={() => goto(`/chate/${event.encode()}`)}
        />
    {/each}
</div>