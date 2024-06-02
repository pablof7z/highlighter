<script lang="ts">
	import { Microphone, Note, Play, RowsPlusBottom, TextAlignLeft } from "phosphor-svelte";
    import NewPostItem from "./NewPostItem.svelte";
	import StreamIcon from "$icons/StreamIcon.svelte";
	import Box from "$components/PageElements/Box.svelte";
	import { drafts } from "$stores/drafts";
	import { openModal, replaceModal } from "$utils/modal";
	import NewPostModal from "$modals/NewPostModal.svelte";

    export let onNewShortPost: (() => void) | undefined = undefined;

    function shortNote() {
        if (!!onNewShortPost) {
            onNewShortPost();
        } else {
            openModal(NewPostModal);
        }
    }
</script>

<Box class={$$props.boxClass} innerClass="flex-col">
    <div class="
        gap-4
        sm:gap-6
        w-full
        grid md:grid-flow-row
        grid-cols-3 md:grid-cols-3
        justify-center
    ">
        <NewPostItem icon={Note} title="Short Note" on:click={shortNote} />
        <NewPostItem icon={TextAlignLeft} title="Article" href="/articles/new" />
        <NewPostItem icon={Play} title="Video" href="/videos/new" />
        <NewPostItem icon={RowsPlusBottom} title="Thread" href="/threads/new" />
        <NewPostItem icon={StreamIcon} title="Live stream" comingSoon={true} />
        <NewPostItem icon={Microphone} title="Podcast" comingSoon={true} />
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