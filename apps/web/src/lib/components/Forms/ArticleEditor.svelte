<script lang="ts">
    import Input from "$components/Forms/Input.svelte";
	import { Textarea, ndk } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { Image } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

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

<div class="flex flex-col border-none border-neutral-800 rounded-xl">
    {#if showBannerInput}
            <Input
                bind:value={imageBanner}
                color="black"
                on:keydown={onImageBannerKeyDown}
                placeholder="Cover image URL"
            />
    {:else if article.image}
        <div class="w-full h-80 relative">
            <button on:click={chooseBanner} class="w-full h-full object-cover relative rounded-xl">
                <img class="w-full h-full object-cover relative rounded-xl" src={article.image} />
            </button>
            <div class="absolute bottom-0 w-full h-2/5 bg-gradient-to-b from-transparent to-black"></div>
            <div class="p-6 absolute bottom-0 w-full">
                <Input
                    bind:value={article.title}
                    color="black"
                    class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] font-semibold placeholder:text-white/50 placeholder:font-normal"
                    placeholder="Add a title"
                    on:keydown={onTitleKeyDown}
                />
            </div>
        </div>
    {:else}
        <div class="flex flex-col items-center justify-center -mt-8 -mb-8 relative rounded-t-lg">
            <div class="tooltip" data-tip="Add cover image">
                <button class="btn btn-lg bg-base-200 border border-neutral-800 btn-circle" on:click={chooseBanner}>
                    <Image class="w-8 h-8" />
                </button>
            </div>
        </div>
    {/if}
    <div class="p-6 flex flex-col gap-4">
        {#if !article.image}
            <Input
                bind:value={article.title}
                color="black"
                class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] font-semibold placeholder:text-white/50 placeholder:font-normal"
                placeholder="Add a title"
            />
        {/if}

        <Textarea
            bind:value={article.content}
            on:keyup={() => dispatch("contentUpdate", article.content)}
            bind:element={contentAreaElement}
            class="
                !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg text-white
                focus:ring-0
                resize-none min-h-[20vh]
            "
            placeholder="Write your heart out..."
        />

        <!-- <div class="relative flex flex-row items-center w-full">
            <Image class="w-5 h-5  text-white absolute left-0" />
            <input type="text" class="!bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg focus:text-white text-neutral-500/50 focus:text-opacity-100 w-full !pl-12" placeholder="Cover image URL" bind:value={image} on:blur={() => article.image = image} />

        </div> -->
    </div>
</div>