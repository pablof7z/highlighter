<script lang="ts">
	import PageTitle from '$components/PageElements/PageTitle.svelte';
	import { pageHeader } from "$stores/layout";
	import ItemViewComments from "$views/Item/ItemViewComments.svelte";
	import { onDestroy } from "svelte";
	import { loadedEvent, title } from "$lib/stores/item-view.js";
	import { openModal } from "$utils/modal";
	import NewPostModal from "$modals/NewPostModal.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    let event;
    $: event = $loadedEvent;

    $: {
        $pageHeader ??= {};
        $pageHeader.right = {
            label: "Comment",
            fn: () => {
                const e = new NDKEvent();
                e.tag(event!, "root");
                openModal(NewPostModal, {
                    tags: e.tags,
                    placeholder: "Write a comment...",
                    title: "New Comment"
                });
            }
        }
    }

    onDestroy(() => {
        if ($pageHeader) {
            $pageHeader.right = undefined;
        }
    })
</script>

<PageTitle title="Comments" defaultTitle={$title} />

{#if event}
    <ItemViewComments {event} />
{/if}