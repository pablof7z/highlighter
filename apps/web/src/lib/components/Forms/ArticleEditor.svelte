<script lang="ts">
    import Input from "$components/Forms/Input.svelte";
	import { Textarea, ndk } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher } from "svelte";

    export let article: NDKArticle = new NDKArticle($ndk, {
        content: "",
    } as NostrEvent);

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

<div class="flex flex-col border-none border-neutral-800 sm:rounded-xl border">
    <div class="p-6 pb-0 w-full">
        <Input
            bind:value={article.title}
            color="black"
            class="!bg-transparent !text-3xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] placeholder:text-white/50 placeholder:font-normal"
            placeholder="Add a title"
            on:keydown={onTitleKeyDown}
            on:change={() => dispatch("titleChanged")}
        />
    </div>
    <div class="p-6 pt-0 flex flex-col gap-4">
        <Textarea
            bind:value={article.content}
            on:keyup={() => dispatch("contentUpdate", article.content)}
            bind:element={contentAreaElement}
            on:change={() => dispatch("contentChanged")}
            fixedHeight={true}
            class="
                !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                focus:ring-0 text-neutral-400
                resize-none min-h-[20vh] h-[70vh]
                font-serif
                {$$props.textareaClass??""}
            "
            placeholder="Write your heart out..."
        />
    </div>
</div>