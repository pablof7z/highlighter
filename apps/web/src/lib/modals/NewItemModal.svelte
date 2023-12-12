<script lang="ts">
	import { closeModal } from "svelte-modals";
    import { createEventDispatcher } from "svelte";
	import { fade } from "svelte/transition";
	import ArticleIcon from '$icons/ArticleIcon.svelte';
	import NoteIcon from '$icons/NoteIcon.svelte';
	import VideoIcon from '$icons/VideoIcon.svelte';
	import StreamIcon from '$icons/StreamIcon.svelte';

    const dispatch = createEventDispatcher();

    async function onClose() {
        closeModal()
        dispatch("close");
    }
</script>

<div class="
    fixed
    h-screen top-0 bottom-0 left-0 px-4 lg:px-0
    flex justify-center items-center
    z-50
    w-screen
" transition:fade on:click={onClose}>
    <div class="
    card
    rounded-3xl
    shadow-xl
    flex flex-col
    relative
    overflow-y-hidden
    {$$props.class}
    " style="pointer-events: auto; max-height: 92vh;" on:click|stopPropagation={()=>{}} transition:fade>
        <div class="bg-white p-8 rounded-2xl shadow-lg p-12">
            <div class="flex flex-col md:flex-row gap-16">

                <a href="/notes/new">
                    <span>
                        <NoteIcon />
                    </span>
                    Note
                </a>

                <a href="/articles/new">
                    <span>
                        <ArticleIcon />
                    </span>
                    Article
                </a>

                <a href="/videos/new">
                    <span>
                        <VideoIcon />
                    </span>
                    Video
                </a>

                <a href="#">
                    <span>
                        <StreamIcon />
                    </span>
                    Stream
                </a>
            </div>
        </div>
    </div>
</div>

<style lang="postcss">
    a {
        @apply px-4 py-3 rounded-xl justify-start items-start gap-2 inline-flex;
        @apply text-black text-sm font-semibold leading-5;
        @apply flex-col justify-start items-center gap-2 inline-flex;

        & > span {
            @apply w-8 h-8 pl-1 pr-0.5 pt-0.5 pb-1 justify-center items-center inline-flex self-center;
        }

        &:hover {
            @apply hover:bg-zinc-100;
        }
    }
</style>