<script lang="ts">
	import ArticleIcon from '$icons/ArticleIcon.svelte';
	import NoteIcon from '$icons/NoteIcon.svelte';
	import VideoIcon from '$icons/VideoIcon.svelte';
	import StreamIcon from '$icons/StreamIcon.svelte';
	import ModalShell from "$components/ModalShell.svelte";
</script>

<ModalShell>
    <div class="">
        <div class="max-sm:grid max-sm:grid-cols-2 gap-8 flex flex-col md:flex-row sm:gap-16">

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
    </ModalShell>

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