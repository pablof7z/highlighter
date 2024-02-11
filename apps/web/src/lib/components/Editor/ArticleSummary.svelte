<script lang="ts">
	import DurationTag from "$components/DurationTag.svelte";
	import { Textarea } from "@kind0/ui-common";
	import type { NDKArticle, NDKKind } from "@nostr-dev-kit/ndk";
    import { countWords } from "$utils/article";
	import DvmGenerateButton from "$components/Dvm/DvmGenerateButton.svelte";

    export let article: NDKArticle;

    let duration: string | undefined;

    $: if (article.summary) {
        duration = article.summary.length > 0 ? `${countWords(article.summary)} words` : undefined;
    } else {
        duration = undefined;
    }
</script>

<div class="field">
    <div class="title">
        Summary
    </div>
    <div class="relative">
        <Textarea
            bind:value={article.summary}
            class="min-h-[10rem] w-full !bg-white/5 rounded-box focus:!border-white/20"
        />
        {#if duration}
            <DurationTag value={duration} class="absolute bottom-2 right-2" />
        {/if}
    </div>

    <!-- <DvmGenerateButton kind={5001} inputs={[[article.content, "text"]]} /> -->

</div>