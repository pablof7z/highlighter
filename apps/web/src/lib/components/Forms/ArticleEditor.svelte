<script lang="ts">
    import Input from "$components/Forms/Input.svelte";
	import { randomVideoThumbnail } from "$utils/skeleton";
	import { Textarea, ndk } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { Image } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import ImageUploader from "./ImageUploader.svelte";

    export let article: NDKArticle = new NDKArticle($ndk, {
        content: "",
    } as NostrEvent);

    const dispatch = createEventDispatcher();

    let showBannerInput = false;
    let imageBanner: string;
    let contentAreaElement: HTMLTextAreaElement;

    function chooseBanner() {
        showBannerInput = true;
    }

	function onImageBannerKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            article.image = imageBanner;
            showBannerInput = false;
        } else if (e.key === "Escape") {
            showBannerInput = false;
        }
	}

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }
</script>

<div class="flex flex-col border-none border-neutral-800 sm:rounded-xl">
    <div class="w-full h-80 relative">
        <ImageUploader
            class="absolute top-0 left-0 w-full h-full object-cover sm:rounded-xl"
            bind:url={article.image}
            let:onOpen
        >
            <div class="bg-base-200 w-full h-full items-center justify-center flex flex-row">
                <button class="btn btn-lg bg-base-200 border border-neutral-800 btn-circle" on:click={() => onOpen()}>
                    <Image class="w-8 h-8" />
                </button>
            </div>
        </ImageUploader>
        <div class="absolute bottom-0 w-full h-2/5 bg-gradient-to-b from-transparent to-black"></div>
        <div class="p-6 pb-0 absolute bottom-0 w-full">
            <Input
                bind:value={article.title}
                color="black"
                class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] font-semibold placeholder:text-white/50 placeholder:font-normal"
                placeholder="Add a title"
                on:keydown={onTitleKeyDown}
            />
        </div>
    </div>


    <div class="p-6 flex flex-col gap-4">
        <Textarea
            bind:value={article.content}
            on:keyup={() => dispatch("contentUpdate", article.content)}
            bind:element={contentAreaElement}
            fixedHeight={true}
            class="
                !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                focus:ring-0
                resize-none min-h-[20vh] h-[70vh]
                {$$props.textareaClass??""}
            "
            placeholder="Write your heart out..."
        />
    </div>
</div>