<script lang="ts">
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
    import Input from '$components/Forms/Input.svelte';
    import { createEventDispatcher } from 'svelte';

    export let video: NDKVideo;

    let title: string | undefined = video.title;

    $: video.title = title;

    function onTitleKeyUp() {
        video.title = title;
        video = video;
    }

    const dispatch = createEventDispatcher();

    let contentAreaElement: HTMLTextAreaElement;

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }
</script>

<div class="flex flex-col mt-4">
    <Input
        bind:value={title}
        color="black"
        class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 !text-white font-['InterDisplay'] font-semibold placeholder:text-white/50 placeholder:font-normal"
        placeholder="Add a title"
        on:keydown={onTitleKeyDown}
        on:keyup={onTitleKeyUp}
    />

    <Textarea
        bind:value={video.content}
        on:keyup={() => {dispatch("contentUpdate", video.content); video = video}}
        bind:element={contentAreaElement}
        class="
            !bg-transparent border-none !px-4 -mx-4 rounded-lg text-white
            focus:ring-0 text-opacity-60
            resize-none min-h-[2rem] text-lg
        "
        placeholder="Description"
    />
</div>
