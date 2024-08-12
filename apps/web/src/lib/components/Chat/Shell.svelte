<script lang="ts">
	import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKFilter, NDKKind, NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMetadata, NDKTag } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy } from "svelte";
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import { derived, Readable, writable } from "svelte/store";
    import * as Groups from "$components/Groups";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { addHistory } from "$stores/history";
	import { ChatCircle } from "phosphor-svelte";
	import Swipe from "$components/Swipe.svelte";
    import { Keyboard } from '@capacitor/keyboard';
	import { isMobileBuild } from '$utils/view/mobile';
	import Joined from "$components/Chat/Joined.svelte";
	import Footer from "./Footer.svelte";
	import { throttle } from "@sveu/shared";

    export let events: Readable<NDKEvent[]>;
    export let eosed: boolean;
    export let tags: NDKTag[];
    export let kind: NDKKind;
    export let setFooter = true;
    
    if (isMobileBuild()) {
        try {
            Keyboard.addListener('keyboardWillShow', scrollToBottom);
        } catch {}
    }
    
    $layout.header = undefined;
    $layout.footerInMain = true;
    $layout.fullWidth = false;
    $layout.headerCanBeTransparent = false;

    function scrollToBottom() {
        const last = $sortedChat[$sortedChat.length - 1];
        const lastElement = document.getElementById(last.id);
        if (lastElement) {
            lastElement.scrollIntoView({ behavior: 'smooth' });
        }
    }

    const throttledScrollToBottom = throttle(scrollToBottom, 50);

    let eventCount = $events.length;
    $: if ($events.length > eventCount) {
        eventCount = $events.length;
        throttledScrollToBottom();
    }

    const sortedChat = derived(events, ($events) => {
        return $events.sort((a, b) => a.created_at! - b.created_at!);
    });

    onDestroy(() => {
        $layout.headerCanBeTransparent = undefined;
    })

    const replyTo = writable<NDKEvent | undefined>(undefined);

    if (setFooter) {
        $layout.footer = {
            component: Footer,
            props: {
                tags,
                kind,
                placeholder: "Say something...",
                replyTo
            }
        }
    }

    // $: if ($chat.length > 0) {
    //     tags = tags.filter((t) => t[0] !== "previous");

    //     const previous = $chat.slice(0, 10)
    //         .map(e => e.id.slice(0, 8))
        
    //     tags.push([ "previous", ...previous ]);

    //     if ($layout.footer?.props) $layout.footer.props.tags = tags;
    // }

    // scroll to bottom on new message
    $: if ($sortedChat.length > 0) {
        const lastMessage = $sortedChat[$sortedChat.length - 1];
        const lastMessageId = lastMessage.id;

        setTimeout(() => {
            const lastMessageElement = document.getElementById(lastMessageId);
            if (lastMessageElement) {
                const opts = eosed ? { behavior: 'smooth' } : {};
                lastMessageElement.scrollIntoView(opts);
            } else {
                console.log('could not find element', lastMessageId);
            }
        }, 100);
    }

    function onReply(event: NDKEvent) {
        $replyTo = event;
    }
</script>

<ScrollArea>
    <div class="flex flex-col py-2">
        {#each $sortedChat as event, i (event.id)}
            {#if event.kind === NDKKind.GroupAdminRequestJoin}
                <!-- <JoinRequest {event} /> -->
            {:else if event.kind === 9000}
                <Joined {event} />
            {:else if [NDKKind.GroupChat, 10, 1311].includes(event.kind)}
            <Swipe
                leftOptions={[
                    { name: 'Reply', icon: ChatCircle, class: "bg-accent", fn: () => onReply(event) },
                ]}
            >
                <ChatBubble
                    {event}
                    skipName={$sortedChat[i - 1]?.pubkey === event.pubkey}
                    skipAvatar={$sortedChat[i + 1]?.pubkey === event.pubkey}
                    skipTime={$sortedChat[i - 1] && $sortedChat[i - 1].created_at > event.created_at - 60}
                >
                    <slot {event} />
                </ChatBubble>
            </Swipe>
            {/if}
            <span id={event.id}></span>
        {/each}
    </div>
</ScrollArea>