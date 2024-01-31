<script lang="ts">
	import { Microphone, Play, TextAlignLeft } from "phosphor-svelte";
    import NewPostItem from "./NewPostItem.svelte";
	import NoteIcon from "$icons/NoteIcon.svelte";
	import StreamIcon from "$icons/StreamIcon.svelte";
	import Box from "$components/PageElements/Box.svelte";
	import { drafts } from "$stores/drafts";
</script>

<Box title="Create New" class={$$props.boxClass} innerClass="flex-col">
    <div class="
        max-sm:gap-8
        gap-6
        w-full
        grid md:grid-flow-col
        grid-cols-1 md:grid-cols-5
        justify-center
    ">
        <NewPostItem icon={TextAlignLeft} title="Article" href="/articles/new" />
        <NewPostItem icon={Play} title="Video" href="/videos/new" />
        <NewPostItem icon={NoteIcon} title="Note" href="/notes/new" />
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