<script lang="ts">
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { Button } from "$components/ui/button";
	import Input from "$components/ui/input/input.svelte";
	import { Textarea } from "$components/ui/textarea";
    import { NDKArticle, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher } from "svelte";
    import { Image, Shuffle } from "phosphor-svelte";
	import { ndk } from "$stores/ndk";
	import { toast } from "svelte-sonner";

    const dispatch = createEventDispatcher();

    export let article: NDKArticle;
    export let forceSave = false;

    let title: string;
    let image: string;
    let description: string;

    $: if (forceSave) { forceSave = false; save(); }

    function uploaded(event: CustomEvent<{url: string}>) {
        const {url} = event.detail;
        image = url;
    }

    async function save() {
        const curation = new NDKList($ndk);
        curation.kind = NDKKind.ArticleCurationSet;
        curation.title = title;
        curation.description = description;
        curation.image = image;

        curation.addItem(article);

        await curation.sign();
        curation.publish();
        dispatch("close");
        toast.success(curation.title + " created with "+article.title);
    }

    function maybeUseRandomImage() {
        if (!image) {
            randomImage();
        }
    }

    async function randomImage() {
        const k = title || "Nature";
        const i = await fetch(`https://picsum.photos/800/600?random=${k}`);
        const finalUrl = i.url;

        if (finalUrl) {
            image = finalUrl;
        }
    }
</script>

<div class="flex flex-col items-center gap-4 mx-2">
    <Input
        bind:value={title}
        on:change={maybeUseRandomImage}
        class="bg-background/50 text-lg"
        placeholder="Title"
        autofocus={true}
    />
    
    <Textarea
        bind:value={description}
        class="bg-background/50 text-lg"
        placeholder="Description"
    />

    <div class="h-48 bg-background/50 rounded overflow-clip relative w-full">
        {#if image}
            <img class="w-full md:!h-48 object-cover" src={image} />
        {/if}
        
        <div class="absolute left-2 bottom-2 flex flex-row justify-between gap-2">
            <BlossomUpload
                on:uploaded={uploaded}
            >
                <Button variant="outline" class="py-2 w-full flex sm:flex-col max-sm:justify-start justify-center items-center gap-2 whitespace-nowrap !h-fit">
                    <Image class="w-8 h-8" />
                </Button>
            </BlossomUpload>

            <Button variant="outline" class="py-2 w-full flex sm:flex-col max-sm:justify-start justify-center items-center gap-2 whitespace-nowrap !h-fit" on:click={randomImage}>
                <Shuffle class="w-8 h-8" />
            </Button>

        </div>
    </div>
</div>