<script lang="ts">
	import { NDKArticle, NDKVideo } from '@nostr-dev-kit/ndk';
	import { Image, Shuffle } from 'phosphor-svelte';
	import Button from '$components/ui/button/button.svelte';
	import BlossomUpload from '$components/buttons/BlossomUpload.svelte';
	import { activeBlossomServer } from '$stores/session';
	import { randomImage } from '$utils/image';

    export let article: NDKArticle | undefined = undefined;
    export let video: NDKVideo | undefined = undefined;

    let title: string | undefined;
    $: title = article?.title ?? video?.title;

    let image: string | undefined;
    $: image = article?.image ?? video?.thumbnail;

    function setUrl(url: string) {
        if (article)
            article.image = url;
        else if (video)
            video.thumbnail = url;
    }

    function uploaded(event: CustomEvent<{url: string}>) {
        const {url} = event.detail;
        setUrl(url);
    }

    async function setImage() {
        const k = title || "Nature" + Math.random();
        setUrl(randomImage(k, 800, 400));
    }
    
</script>

<section class="w-full">
    <div class="field">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div class="relative col-span-2 row-span-2 flex items-stretch justify-stretch bg-secondary/50 rounded" class:max-sm:hidden={!image}>
                {#if image}
                    <img class="w-full md:!h-72 object-cover" src={image} />
                {/if}
            </div>

            <div class="relative">
                <BlossomUpload
                    class="w-full"
                    on:uploaded={uploaded}
                >
                    <Button variant="secondary" class="py-4 w-full flex sm:flex-col max-sm:justify-start justify-center items-center gap-2 whitespace-nowrap !h-fit">
                        <Image class="w-12 h-12" />
                        Upload a cover image
                    </Button>
                </BlossomUpload>
            </div>

            <Button variant="secondary" class="py-4 w-full flex sm:flex-col max-sm:justify-start justify-center items-center gap-2 whitespace-nowrap !h-fit" on:click={setImage}>
                <Shuffle class="w-12 h-12" />

                Random Image
            </Button>
        </div>

        <!-- {#if article.title}
            <DvmGenerateButton kind={NDKKind.DVMReqImageGeneration} inputs={[[article.title, "text"]]} />
        {/if} -->
    </div>
</section>
