<script lang="ts">
	import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKSimpleGroupMetadata, NDKTag } from "@nostr-dev-kit/ndk";
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
	import { Navigation } from "$utils/navigation";
	import Joined from "$components/Chat/Joined.svelte";
	import { markGroupEventSeen } from "$stores/notifications";

    export let group = getContext('group') as NDKSimpleGroup;
    export let metadata = getContext("groupMetadata") as Readable<NDKSimpleGroupMetadata>;
    const isMember = getContext("isMember") as Readable<boolean>;
    const optionManager = getContext("optionManager") as Navigation;
    optionManager.options.subscribe(value => $layout.navigation = value);

    addHistory({ category: 'Chat', title: $metadata?.name ?? "Community" });

    if (isMobileBuild()) {
        try {
            Keyboard.addListener('keyboardWillShow', scrollToBottom);
        } catch {}
    }
    
    $layout.header = undefined;
    $: if ($isMember) $layout.title = "Chat";
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

    function onEvent() { setTimeout(scrollToBottom, 50); }

    let eosed = false;
    function onEose() {
        setTimeout(() => eosed = true, 5000);
    }

    const chat = $ndk.storeSubscribe([
        {"#h": [group.groupId]},
        {"#d": [group.groupId]},
    ], { groupable: false, subId: 'group-content', relaySet: group.relaySet, onEvent, onEose });

    const sortedChat = derived(chat, ($chat) => {
        return $chat.sort((a, b) => a.created_at! - b.created_at!);
    });

    onDestroy(() => {
        chat.unsubscribe();
        $layout.headerCanBeTransparent = undefined;
    })

    let tags: NDKTag[] = [ [ "h", group.groupId ] ];

    const replyTo = writable<NDKEvent | undefined>(undefined);

    $: if ($isMember) {
        $layout.footer = {
            component: Groups.Footers.Chat,
            props: {
                tags,
                group,
                kind: NDKKind.GroupChat,
                placeholder: "Say something...",
                replyTo
            }
        }
    }

    $: if ($chat.length > 0) {
        tags = tags.filter((t) => t[0] !== "previous");

        const previous = $chat.slice(0, 10)
            .map(e => e.id.slice(0, 8))
        
        tags.push([ "previous", ...previous ]);

        if ($layout.footer?.props) $layout.footer.props.tags = tags;
    }

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
            {:else if event.kind === NDKKind.GroupChat}
            <Swipe
                leftOptions={[
                    { name: 'Reply', icon: ChatCircle, class: "bg-accent", fn: () => onReply(event) },
                ]}
            >
                <ChatBubble
                    {event}
                    on:click={() => onReply(event)}
                    skipName={$chat[i - 1]?.pubkey === event.pubkey}
                    skipAvatar={$chat[i + 1]?.pubkey === event.pubkey}
                    skipTime={$chat[i - 1] && $chat[i - 1].created_at > event.created_at - 60}
                />
            </Swipe>
            {/if}
            <span id={event.id}></span>
        {/each}
    </div>
</ScrollArea>