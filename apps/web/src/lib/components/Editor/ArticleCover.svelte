<script lang="ts">
	import { NDKArticle, NDKVideo } from '@nostr-dev-kit/ndk';
	import ImageUploader from "$components/Forms/ImageUploader.svelte";
	import { Image, Shuffle } from 'phosphor-svelte';

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

    async function randomImage() {
        const k = title || "Nature";
        const image = await fetch(`https://picsum.photos/800/600?random=${k}`);
        const finalUrl = image.url;

        if (finalUrl) {
            setUrl(finalUrl);
        }
    }
    
</script>

<section class="w-full">
    <div class="field">
        <div class="grid grid-cols-3 gap-4">
            <div class="relative rounded-box bg-base-100 col-span-2 row-span-2 flex items-stretch justify-stretch">
                {#if image}
                    <img class="w-full md:!h-72 object-cover" src={image} />
                {/if}
            </div>

            <div class="relative">
                <ImageUploader
                    wrapperClass="w-full"
                    bind:url={image}
                    alwaysUseSlot={true}
                    let:onOpen
                    on:uploaded={uploaded}
                >
                    <button class="side-button w-full" on:click={onOpen}>
                        <Image class="w-12 h-12" />
                        Upload a cover image
                    </button>
                </ImageUploader>
            </div>

            <button class="side-button" on:click={randomImage}>
                <Shuffle class="w-12 h-12" />

                Random Image
            </button>
        </div>

        <!-- {#if article.title}
            <DvmGenerateButton kind={NDKKind.DVMReqImageGeneration} inputs={[[article.title, "text"]]} />
        {/if} -->
    </div>
</section>

<style lang="postcss">
    .side-button {
        @apply py-6 rounded-box flex flex-col justify-center items-center gap-2 bg-white/5 text-white whitespace-nowrap;
    }
</style>