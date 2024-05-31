<script lang="ts">
	import currentUser from '$stores/currentUser';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import ChatInput from '$components/Chat/Input.svelte';
	import { isKind } from '$utils/event';
	import { page } from "$app/stores";
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NDKTag, getRootEventId } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable, derived, writable } from "svelte/store";
	import { pageHeader } from '$stores/layout';
	import { goto } from '$app/navigation';
	import { wot, wotFilter, wotFiltered } from '$stores/wot';
	import { CaretLeft } from 'phosphor-svelte';

    let topEventId: string;
    let root = writable<NDKEvent | null>(null);
    let taggedEvents: NDKEventStore<NDKEvent>;
    let replies: Readable<NDKEvent[]> | undefined;
    let convesationRootId: string | null | undefined;

    let tags: NDKTag[] = [];

    $: {
        convesationRootId = $root ? getRootEventId($root) : undefined;

        $pageHeader ??= {};
        
        if (convesationRootId) {
            $pageHeader.left = {
                url: `/chate/${convesationRootId}`,
                label: 'Back'
            }
            $pageHeader.title = 'Conversation';
        } else {
            $pageHeader.left = {
                url: `/chate`,
                label: 'Back'
            }
            $pageHeader.title = 'Conversation';
        }
    }
    
    $: if (topEventId !== $page.params.id) {
        topEventId = $page.params.id;
        root.set(null);

        $ndk.fetchEvent(topEventId).then(e => {
            if (!e) return;
            taggedEvents = $ndk.storeSubscribe(
                e.filter()
            )
            root.set(e);
            const v = new NDKEvent();
            v.tag(e, "reply");
            tags = v.tags;

            $pageHeader ??= {};
            $pageHeader.footer = {
                component: ChatInput,
                props: {
                    tags,
                    event: $root,
                    kind: NDKKind.Text,
                    showReplyingTo: !!selectEvent
                }
            };

            replies = derived([taggedEvents!, root], ([$taggedEvents, $root]) => {
                if (!$root) return [];

                return $taggedEvents
                    .filter(isKind(NDKKind.Text))
                    .filter(wotFilter)
                    // .filter((e: NDKEvent) => eventIsReply($root, e))
                    .sort((a: NDKEvent, b: NDKEvent) => a.created_at! - b.created_at!);
            });
        });
    }

    let selectedEvent: NDKEvent | undefined = undefined;

    function selectEvent(e: NDKEvent) {
        if (selectedEvent?.id === e.id) {
            goto(`/chate/${selectedEvent.encode()}`)
        } else {
            selectedEvent = e;
            if ($pageHeader?.footer) {
                $pageHeader.footer.props.showReplyingTo = true;
                $pageHeader.footer.props.event = e;
            }
        }
    }

    let hasRepliesFromCurrentUser: boolean;

    $: if ($replies && $currentUser && !selectEvent) {
        hasRepliesFromCurrentUser = $replies.some(e => e.pubkey === $currentUser.pubkey); 

        const mostRecentReply = $replies.sort((a, b) => b.created_at! - a.created_at!)[0];
        if (mostRecentReply && $pageHeader?.footer) {
                $pageHeader.footer.props.showReplyingTo = true;
                $pageHeader.footer.props.event = mostRecentReply;
            }
    }
</script>

{#key $root?.id}
    {#if $replies}
        <div class="flex flex-col grow justify-end gap-6 overflow-y-auto scrollable-content relative">
            {#each $replies as event (event.id)}
                <ChatBubble
                    {event}ChatBubble
                    on:click={() => selectEvent(event)}
                    class="{event.id === $pageHeader?.footer?.props?.event?.id ? 'brightness-150' : ''}"
                />
            {/each}
        </div>
    {/if}
{/key}