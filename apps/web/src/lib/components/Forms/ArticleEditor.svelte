<script lang="ts">
	import { markdownEditor } from './../../stores/settings.ts';
    import Input from "$components/Forms/Input.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher } from "svelte";
	import ContentEditor from './ContentEditor.svelte';

    export let article: NDKArticle = new NDKArticle($ndk, {
        content: "",
    } as NostrEvent);

    const dispatch = createEventDispatcher();

    let contentAreaElement: HTMLElement;

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }

</script>

<ContentEditor
    bind:content={article.content}
    on:contentChanged
    on:submit
    on:focus
    on:blur
    class="font-serif text-lg min-h-[50vh]"
>
    <div slot="belowToolbar" class="p-6 pb-0 w-full">
        <Input
            bind:value={article.title}
            color="black"
            class="!bg-transparent !text-3xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] placeholder:text-white/50 placeholder:font-normal"
            placeholder="Add a title"
            on:keydown={onTitleKeyDown}
            on:change={() => dispatch("titleChanged")}
        />
    </div>
</ContentEditor>

<div class="hidden min-h-[20rem]"></div>