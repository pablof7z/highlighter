<script lang="ts">
    import NewPostItem from "./NewPostItem.svelte";
	import { closeModal, openModal } from "$utils/modal";
	import { createEventDispatcher } from "svelte";
	import NewGroupModal from "$modals/NewGroupModal.svelte";

    export let onNewShortPost: (() => void) | undefined = undefined;

    const dispatch = createEventDispatcher();

    function shortNote() {
        // if (!!onNewShortPost) {
        //     onNewShortPost();
        // } else {
        dispatch("close");
            // openModal(NewPostModal);
        // }
    }

    function newCommunity() {
        dispatch("close");
        openModal(NewGroupModal);
    }
</script>

<div class="
    gap-3
    w-full
    grid md:grid-flow-row
    grid-cols-2 md:grid-cols-2
    justify-center
">
    <NewPostItem icon='🤙' title="Short Not2e2" on:click={shortNote} />
    <NewPostItem icon="🗒️" title="Article" href="/studio/article" on:click={closeModal} />
    <NewPostItem icon='🎬 ' title="Video" href="/videos/new" on:click={closeModal} />
    <NewPostItem icon='🧵' title="Thread" href="/studio/threads/new" on:click={closeModal} />
    <NewPostItem icon='⏱️' title="Scheduled Posts" href="/schedule" on:click={closeModal} />
    <NewPostItem icon='🖋️' title="Drafts" href="/drafts" on:click={closeModal} />
    <NewPostItem icon='🏰' title="Community" on:click={newCommunity} class="col-span-2" />
</div>
