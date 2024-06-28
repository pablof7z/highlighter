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
        if (!!onNewShortPost) {
            onNewShortPost();
        } else {
            // openModal(NewPostModal);
        }
    }
</script>

<Box class={$$props.boxClass} innerClass="flex-col">
    <div class="
        gap-4
        sm:gap-6
        w-full
        grid md:grid-flow-row
        grid-cols-2 md:grid-cols-2
        justify-center
    ">
        <NewPostItem icon={Note} title="Short Note" on:click={shortNote} />
        <NewPostItem icon={TextAlignLeft} title="Article" href="/articles/new" on:click={closeModal} />
        <NewPostItem icon={Play} title="Video" href="/videos/new" on:click={closeModal} />
        <NewPostItem icon={RowsPlusBottom} title="Thread" href="/threads/new" on:click={closeModal} />
        <NewPostItem icon={Timer} title="Scheduled Posts" href="/schedule" on:click={closeModal} />
        <NewPostItem icon={PencilLine} title="Drafts" href="/drafts" on:click={closeModal} />
    </div>
    {#if $drafts?.length > 0}
        <div class="self-start">
            <a href="/drafts" class="btn btn-ghost !rounded-full w-fit font-normal">
                <span class="gradient-text">
                    {$drafts.length}
                    Drafts
                </span>
            </a>
        </div>
    {/if}
</Box>