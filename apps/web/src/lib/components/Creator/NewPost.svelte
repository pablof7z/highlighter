<script lang="ts">
	import { Microphone, Note, PencilLine, Play, RowsPlusBottom, TextAlignLeft, Timer } from "phosphor-svelte";
    import NewPostItem from "./NewPostItem.svelte";
	import StreamIcon from "$icons/StreamIcon.svelte";
	import Box from "$components/PageElements/Box.svelte";
	import { drafts } from "$stores/drafts";
	import { closeModal, openModal, replaceModal } from "$utils/modal";
	import NewPostModal from "$modals/NewPostModal.svelte";

    export let onNewShortPost: (() => void) | undefined = undefined;

    function shortNote() {
        // if (!!onNewShortPost) {
        //     onNewShortPost();
        // } else {
            openModal(NewPostModal);
        // }
    }
</script>

<div class="
    gap-3
    w-full
    grid md:grid-flow-row
    grid-cols-2 md:grid-cols-2
    justify-center
">
    <NewPostItem icon='🤙' title="Short Note" on:click={shortNote} />
    <NewPostItem icon="🗒️" title="Article" href="/articles/new" on:click={closeModal} />
    <NewPostItem icon='🎬 ' title="Video" href="/videos/new" on:click={closeModal} />
    <NewPostItem icon='🧵' title="Thread" href="/threads/new" on:click={closeModal} />
    <NewPostItem icon='⏱️' title="Scheduled Posts" href="/schedule" on:click={closeModal} />
    <NewPostItem icon='🖋️' title="Drafts" href="/drafts" on:click={closeModal} />
    <NewPostItem icon='🏰' title="Community" href="/communities" on:click={closeModal} class="col-span-2" />
</div>
