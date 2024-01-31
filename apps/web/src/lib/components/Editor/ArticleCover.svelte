<script lang="ts">
	import { NDKArticle, NDKKind } from '@nostr-dev-kit/ndk';
    import Image from "phosphor-svelte/lib/Image"

	import ImageUploader from "$components/Forms/ImageUploader.svelte";
	import DvmGenerateButton from '$components/Dvm/DvmGenerateButton.svelte';

    export let article: NDKArticle;
</script>

<div class="field">
    <div class="title">
        Cover Image
    </div>
    <ImageUploader
        class="w-full h-full max-h-80 object-cover sm:rounded-xl"
        bind:url={article.image}
        let:onOpen
    >
        <div class="bg-white/5 w-full h-full items-center justify-center flex flex-row p-6 rounded-box">
            <button class="btn btn-lg bg-white/5 border border-neutral-800 btn-circle" on:click={() => onOpen()}>
                <Image class="w-8 h-8" />
            </button>
        </div>
    </ImageUploader>

    {#if article.title}
        <DvmGenerateButton kind={NDKKind.DVMReqImageGeneration} inputs={[[article.title, "text"]]} />
    {/if}
</div>