<script lang="ts">
	import { NDKArticle, NDKKind } from '@nostr-dev-kit/ndk';
	import ImageUploader from "$components/Forms/ImageUploader.svelte";
	import AiIcon from '$icons/AiIcon.svelte';
	import ImageIcon from '$icons/ImageIcon.svelte';

    export let article: NDKArticle;

    function uploaded(event: CustomEvent<{url: string}>) {
        const {url} = event.detail;
        article.image = url;
    }
</script>

<section class="settings">
    <div class="field">
        <div class="title">
            Cover Image
        </div>
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
                        <ImageIcon class="w-12 h-12" />
                        Upload a cover image
                    </button>
                </ImageUploader>
            </div>

            <button class="side-button" disabled>
                <AiIcon class="w-12 h-12" />

                Generate Image
                <div class="badge">
                    Coming soon
                </div>
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