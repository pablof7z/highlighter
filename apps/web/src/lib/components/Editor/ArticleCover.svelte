<script lang="ts">
	import { NDKArticle, NDKKind } from '@nostr-dev-kit/ndk';
	import ImageUploader from "$components/Forms/ImageUploader.svelte";
	import { Image, Shuffle } from 'phosphor-svelte';

    export let article: NDKArticle;

    function uploaded(event: CustomEvent<{url: string}>) {
        const {url} = event.detail;
        article.image = url;
    }

    async function randomImage() {
        const title = article.title || "Nature";
        const image = await fetch(`https://picsum.photos/800/600?random=${title}`);
        const finalUrl = image.url;

        if (finalUrl) {
            article.image = finalUrl;
        }
    }
    
</script>

<section class="w-full">
    <div class="field">
        <div class="grid grid-cols-3 gap-4">
            <div class="relative rounded-box bg-base-100 col-span-2 row-span-2 flex items-stretch justify-stretch">
                {#if article.image}
                    <img class="w-full md:!h-72 object-cover" src={article.image} />
                {/if}
            </div>

            <div class="relative">
                <ImageUploader
                    wrapperClass="w-full"
                    bind:url={article.image}
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