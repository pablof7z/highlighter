<script lang="ts">
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
    import Input from '$components/ui/input/input.svelte';
    import { createEventDispatcher } from 'svelte';
	import Textarea from "$components/ui/textarea/textarea.svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";

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

<div class="flex flex-col mt-4 border p-4 rounded gap-2">
    <Input
        bind:value={title}
        class="!bg-transparent text-2xl border-none !p-0 focus:ring-0 !text-foreground font-['InterDisplay'] font-semibold placeholder:text-muted-foreground placeholder:font-normal focus-visible:!ring-0 focus-visible:!outline-0 focus-visible:!shadow-none"
        placeholder="Title"
        on:keydown={onTitleKeyDown}
        on:keyup={onTitleKeyUp}
    />

    <ContentEditor
        bind:value={video.content}
        on:keyup={() => {dispatch("contentUpdate", video.content); video = video}}
        bind:element={contentAreaElement}
        toolbar={false}
        class="
            !bg-transparent border-none rounded-lg text-foreground
            focus:ring-0 text-opacity-60
            resize-none min-h-[2rem]
        "
        placeholder="Description"
    />
</div>
